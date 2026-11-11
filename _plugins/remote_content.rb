# frozen_string_literal: true

require "cgi"
require "digest"
require "fileutils"
require "json"
require "net/http"
require "uri"
require "nokogiri"
require "rouge"

module BeejBlog
  # Split tokens at line boundaries without breaking multiline highlighting spans.
  class GistCodeFormatter < Rouge::Formatter
    def initialize(prefix, trailing_newline)
      @prefix = prefix
      @trailing_newline = trailing_newline
      @html = Rouge::Formatters::HTML.new
    end

    def stream(tokens)
      lines = token_lines(tokens).to_a
      lines = [[]] if lines.empty?
      lines.each_with_index do |line, index|
        number = index + 1
        anchor = "#{@prefix}-L#{number}"
        newline = index < lines.length - 1 || @trailing_newline ? "\n" : ""
        yield "<span class=\"gist-code-line\" id=\"#{anchor}\"><a class=\"gist-line-number\" href=\"##{anchor}\" data-line-number=\"#{number}\" aria-label=\"Link to line #{number}\"></a><span class=\"gist-line-content\">#{@html.format(line)}#{newline}</span></span>"
      end
    end
  end

  # One instance per site build: always refresh, but fetch duplicate URLs only once.
  class RemoteContent
    MAX_BYTES = 5 * 1024 * 1024

    def initialize(site)
      @site = site
      @responses = {}
    end

    def fetch(url)
      @responses[url] ||= begin
        path = File.join(@site.source, "_remote_content", "#{Digest::SHA256.hexdigest(url)}.json")
        begin
          body = request(url)
        rescue StandardError => error
          snapshot = File.file?(path) ? JSON.parse(File.read(path, encoding: "UTF-8")) : nil
          unless snapshot && snapshot["url"] == url && snapshot["body"].is_a?(String)
            raise Jekyll::Errors::FatalException, "Cannot fetch #{url}; no snapshot available: #{error.message}"
          end
          Jekyll.logger.warn "Remote content:", "Using saved snapshot for #{url}: #{error.message}"
          body = snapshot["body"]
        else
          FileUtils.mkdir_p(File.dirname(path))
          saved = JSON.pretty_generate({ "url" => url, "body" => body }) + "\n"
          File.write(path, saved) unless File.file?(path) && File.read(path, encoding: "UTF-8") == saved
        end
        body
      end
    end

    def request(url, redirects = 5)
      uri = URI.parse(url)
      unless uri.is_a?(URI::HTTPS) && uri.host && !uri.userinfo
        raise ArgumentError, "Remote content requires an HTTPS URL without credentials"
      end
      raise ArgumentError, "Too many redirects" if redirects.negative?

      headers = { "User-Agent" => "BeejBlog-Jekyll", "Accept" => "*/*" }
      token = ENV["GITHUB_TOKEN"]
      headers["Authorization"] = "Bearer #{token}" if uri.host == "api.github.com" && token && !token.empty?
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 15
      http.read_timeout = 30
      body = +""
      http.request(Net::HTTP::Get.new(uri.request_uri, headers)) do |response|
        case response
        when Net::HTTPSuccess
          response.read_body do |chunk|
            body << chunk
            raise IOError, "Response exceeds #{MAX_BYTES} bytes" if body.bytesize > MAX_BYTES
          end
        when Net::HTTPRedirection
          return request(URI.join(url, response.fetch("location")).to_s, redirects - 1)
        else
          raise IOError, "HTTP #{response.code}"
        end
      end
      body.force_encoding(Encoding::UTF_8)
      raise IOError, "Response is not UTF-8 text" unless body.valid_encoding?
      body
    end

    def markdown(text, source_url)
      converter = @site.find_converter_instance(Jekyll::Converters::Markdown)
      fragment = Nokogiri::HTML.fragment(converter.convert(text))
      uri = URI.parse(source_url)
      # GitHub serves files from raw URLs, but document links should open its UI.
      document_base = source_url
      if uri.host == "raw.githubusercontent.com"
        owner, repo, revision, *path = uri.path.delete_prefix("/").split("/")
        document_base = "https://github.com/#{owner}/#{repo}/blob/#{revision}/#{path.join('/')}"
      end
      fragment.css("a[href], img[src], source[src], video[src], video[poster]").each do |node|
        %w[href src poster].each do |attribute|
          value = node[attribute]
          next unless value && !value.empty?
          next if value.start_with?("#", "//") || value.match?(%r{\A[a-z][a-z0-9+.-]*:}i)
          base = attribute == "href" ? document_base : source_url
          if uri.host == "raw.githubusercontent.com" && value.start_with?("/")
            base = attribute == "href" ? "https://github.com/#{owner}/#{repo}/blob/#{revision}/" : "https://raw.githubusercontent.com/#{owner}/#{repo}/#{revision}/"
            value = value.delete_prefix("/")
          end
          node[attribute] = URI.join(base, value.gsub(" ", "%20")).to_s
        end
      end
      fragment.to_html
    end

    def gist(id, filename = nil, anchor_suffix = "")
      data = JSON.parse(fetch("https://api.github.com/gists/#{id}"))
      files = data.fetch("files").values
      files.select! { |file| file["filename"] == filename } if filename
      raise ArgumentError, "Gist #{id} has no matching files" if files.empty?
      gist_url = data.fetch("html_url", "https://gist.github.com/#{id}")
      rendered_files = files.sort_by { |file| [file["filename"].match?(/\Areadme\./i) ? 0 : 1, file["filename"]] }.map do |file|
        name = file.fetch("filename")
        raw = file.fetch("raw_url")
        file_anchor = name.downcase.gsub(/[^\p{Alnum}_-]+/, "-").gsub(/\A-+|-+\z/, "")
        source_url = CGI.escapeHTML("#{gist_url}#file-#{file_anchor}")
        source_link = "<a class=\"remote-gist-source\" href=\"#{source_url}\" target=\"BeejBlogGistSource\" title=\"Open this file in the shared Gist window\">source gist</a>"
        heading = "<h3 class=\"remote-gist-file-heading\"><span class=\"remote-gist-filename\">#{CGI.escapeHTML(name)}</span> #{source_link}</h3>\n"
        # Shortcut and other binary attachments are useful downloads, not code.
        if name.match?(/\.(lnk|zip|exe|dll|png|jpe?g|gif|pdf)\z/i) || file.fetch("content", "").include?("\0")
          heading + "<p><a href=\"#{CGI.escapeHTML(raw)}\">Download #{CGI.escapeHTML(name)}</a></p>"
        else
          content = file["truncated"] ? fetch(raw) : file.fetch("content")
          if name.match?(/\.(md|markdown)\z/i)
            heading + markdown(content, raw)
          else
            lexer = begin
              Rouge::Lexer.guess(filename: name, source: content)
            rescue Rouge::Lexer::Guesser::Ambiguous
              Rouge::Lexers::PlainText.new
            end
            prefix = "gist-#{id}-#{Digest::SHA256.hexdigest(name)[0, 10]}#{anchor_suffix}"
            code = GistCodeFormatter.new(prefix, content.end_with?("\n")).format(lexer.lex(content))
            digits = [content.lines.count, 1].max.to_s.length
            heading + "<div class=\"highlighter-rouge\"><div class=\"highlight gist-numbered\" style=\"--gutter-digits: #{digits}\"><pre class=\"highlight\"><code>#{code}</code></pre></div></div>"
          end
        end
      end.join("\n")
      rendered_files
    end
  end

  class RemoteTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @arguments = markup.scan(/"([^"]*)"|'([^']*)'/).map { |pair| pair.compact.first }
      remainder = markup.gsub(/"[^"]*"|'[^']*'/, "").strip
      count = tag_name == "remote_gist" ? (1..2) : (1..1)
      unless remainder.empty? && count.cover?(@arguments.length) && @arguments.none?(&:empty?)
        raise ArgumentError, "Usage: {% #{tag_name} \"#{tag_name == 'remote_gist' ? 'gist-id' : 'https://.../README.md'}\" %}"
      end
      @kind = tag_name
    end

    def render(context)
      site = context.registers[:site]
      content = site.instance_variable_get(:@beej_remote_content)
      unless content
        content = RemoteContent.new(site)
        site.instance_variable_set(:@beej_remote_content, content)
      end
      if @kind == "remote_gist"
        id, filename = @arguments
        raise ArgumentError, "Expected a hexadecimal Gist ID" unless id.match?(/\A[0-9a-f]+\z/i)
        occurrences = context.registers[:beej_remote_gist_occurrences] ||= Hash.new(0)
        occurrences[id] += 1
        suffix = occurrences[id] > 1 ? "-embed-#{occurrences[id]}" : ""
        html = content.gist(id, filename, suffix)
      else
        url = @arguments.first
        html = content.markdown(content.fetch(url), url)
      end
      "\n\n<div class=\"remote-content\" markdown=\"0\">\n#{html}\n</div>\n\n"
    end
  end
end

Jekyll::Hooks.register :site, :after_reset do |site|
  site.remove_instance_variable(:@beej_remote_content) if site.instance_variable_defined?(:@beej_remote_content)
end

Liquid::Template.register_tag("remote_markdown", BeejBlog::RemoteTag)
Liquid::Template.register_tag("remote_gist", BeejBlog::RemoteTag)
