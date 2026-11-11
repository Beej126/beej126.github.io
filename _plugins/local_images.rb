# frozen_string_literal: true

require_relative "remote_content"

module BeejBlog
  # Keep rendered imports independent of the original image hosts, including
  # images newly added to an upstream README after the initial migration.
  class LocalImages
    def initialize(site)
      @site = site
      @mapping = site.data["local_images"] ||= {}
      @failures = {}
      @changed = false
    end

    def self.extension(data)
      return ".png" if data.start_with?("\x89PNG\r\n\x1a\n".b)
      return ".jpg" if data.start_with?("\xff\xd8\xff".b)
      return ".gif" if data.start_with?("GIF87a", "GIF89a")
      return ".webp" if data[0, 4] == "RIFF" && data[8, 4] == "WEBP"
      return ".bmp" if data.start_with?("BM")
      return ".svg" if data[0, 1000].downcase.include?("<svg")
      return ".avif" if data[4, 4] == "ftyp" && %w[avif avis].include?(data[8, 4])
      raise IOError, "Response is not a recognized image"
    end

    def download(url, redirects = 5)
      uri = URI.parse(url.gsub(" ", "%20"))
      raise ArgumentError, "Expected an HTTP(S) image URL" unless %w[http https].include?(uri.scheme) && !uri.userinfo
      raise IOError, "Too many redirects" if redirects.negative?
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 10
      http.read_timeout = 20
      data = +"".b
      http.request(Net::HTTP::Get.new(uri.request_uri, "User-Agent" => "BeejBlog-image-preservation/1.0")) do |response|
        case response
        when Net::HTTPSuccess
          response.read_body do |chunk|
            data << chunk
            raise IOError, "Image exceeds 30 MB" if data.bytesize > 30 * 1024 * 1024
          end
        when Net::HTTPRedirection
          return download(URI.join(url, response.fetch("location")).to_s, redirects - 1)
        else
          raise IOError, "HTTP #{response.code}"
        end
      end
      [data, self.class.extension(data)]
    end

    def localize(url, document)
      return url unless url.start_with?("http://", "https://", "//")
      uri = URI.parse((url.start_with?("//") ? "https:#{url}" : url).gsub(" ", "%20"))
      own_host = URI.parse(@site.config["url"].to_s).host
      if uri.host && own_host && uri.host.casecmp?(own_host)
        local_path = URI::DEFAULT_PARSER.unescape(uri.path)
        baseurl = @site.config["baseurl"].to_s
        disk_path = local_path.delete_prefix(baseurl).delete_prefix("/")
        return local_path if File.file?(File.join(@site.source, disk_path))
      end
      local = @mapping[url]
      return local if local && File.file?(File.join(@site.source, local.delete_prefix("/")))
      return "/assets/img/image-unavailable.svg" if @failures[url]
      begin
        if url.start_with?("//images/") && File.file?(File.join(@site.source, url.delete_prefix("//")))
          local = url.delete_prefix("/")
        else
          data, extension = download(url.start_with?("//") ? "https:#{url}" : url)
          year = document.respond_to?(:date) ? document.date.year : Time.now.year
          local = "/images/uploads/#{year}/remote-#{Digest::SHA256.hexdigest(url)[0, 16]}#{extension}"
          path = File.join(@site.source, local.delete_prefix("/"))
          FileUtils.mkdir_p(File.dirname(path))
          File.binwrite(path, data)
          @site.static_files << Jekyll::StaticFile.new(@site, @site.source, File.dirname(local).delete_prefix("/"), File.basename(local))
        end
        @mapping[url] = local
        @changed = true
        local
      rescue StandardError => error
        @failures[url] = error.message
        Jekyll.logger.warn "External image:", "#{url}: #{error.message}; try scripts/localize-images.py --archive --apply"
        "/assets/img/image-unavailable.svg"
      end
    end

    def render(document)
      return unless document.output_ext == ".html"
      fragment = Nokogiri::HTML.parse(document.output)
      changed = false
      fragment.css("img").each do |node|
        if node["src"]
          original = node["src"]
          node["src"] = localize(original, document)
          changed ||= original != node["src"]
        end
        if node["srcset"]
          original = node["srcset"]
          node["srcset"] = original.split(",").map do |candidate|
            url, descriptor = candidate.strip.split(/\s+/, 2)
            [localize(url, document), descriptor].compact.join(" ")
          end.join(", ")
          changed ||= original != node["srcset"]
        end
      end
      fragment.css("a[href]").each do |node|
        local = @mapping[node["href"]]
        if local
          node["href"] = local
          changed = true
        end
      end
      document.output = fragment.to_html if changed
    end

    def save
      return unless @changed
      path = File.join(@site.source, "_data", "local_images.json")
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, JSON.pretty_generate(@mapping.sort.to_h) + "\n")
      @changed = false
    end
  end
end

Jekyll::Hooks.register [:documents, :pages], :post_render do |document|
  site = document.site
  images = site.instance_variable_get(:@beej_local_images) || BeejBlog::LocalImages.new(site)
  site.instance_variable_set(:@beej_local_images, images)
  images.render(document)
end

Jekyll::Hooks.register :site, :post_write do |site|
  site.instance_variable_get(:@beej_local_images)&.save
end

Jekyll::Hooks.register :site, :after_reset do |site|
  site.remove_instance_variable(:@beej_local_images) if site.instance_variable_defined?(:@beej_local_images)
end
