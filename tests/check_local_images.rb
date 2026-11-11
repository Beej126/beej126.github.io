# frozen_string_literal: true

# Integration audit of built pages: image sources and full-size image links must
# resolve to files in the output directory, including rendered remote imports.
require "nokogiri"
require "uri"

root = File.expand_path(ARGV.fetch(0))
errors = []
pages = Dir.glob(File.join(root, "**", "*.html"))
pages.each do |page|
  document = Nokogiri::HTML(File.read(page))
  urls = document.css("img[src]").map { |node| node["src"] }
  document.css("img[srcset]").each do |node|
    urls.concat(node["srcset"].split(",").map { |candidate| candidate.strip.split(/\s+/, 2).first })
  end
  document.css("a[href]").each do |node|
    urls << node["href"] if node["href"].match?(/\.(png|jpe?g|gif|webp|svg|bmp)([?#]|$)/i)
  end
  urls.each do |url|
    next if url.start_with?("data:")
    uri = URI.parse(url.gsub(" ", "%20"))
    if uri.host
      errors << "#{page}: external image #{url}"
      next
    end
    path = URI::DEFAULT_PARSER.unescape(uri.path)
    local = path.start_with?("/") ? File.join(root, path.delete_prefix("/")) : File.expand_path(path, File.dirname(page))
    errors << "#{page}: missing local image #{url}" unless File.file?(local)
  end
end
abort(errors.join("\n")) unless errors.empty?
puts "PASS: #{pages.length} built HTML pages have local, existing image sources and image links."
