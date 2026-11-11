# frozen_string_literal: true

require "nokogiri"
require "uri"

root = File.expand_path(ARGV.fetch(0))
errors = []
external = Hash.new(0)
Dir.glob(File.join(root, "**", "*.html")).each do |page|
  doc = Nokogiri::HTML(File.read(page))
  assets = doc.css('script[src]').map { |node| node['src'] }
  assets.concat(doc.css('link[rel="stylesheet"]').map { |node| node['href'] })
  assets.each do |url|
    uri = URI.parse(url)
    if uri.host
      external["#{uri.host}#{uri.path}"] += 1
      allowed = (uri.host == 'utteranc.es' && uri.path == '/client.js') ||
                (uri.host == 'www.googletagmanager.com' && uri.path == '/gtag/js')
      errors << "#{page}: unexpected external theme asset #{url}" unless allowed
    else
      path = URI::DEFAULT_PARSER.unescape(uri.path)
      local = path.start_with?('/') ? File.join(root, path.delete_prefix('/')) : File.expand_path(path, File.dirname(page))
      errors << "#{page}: missing asset #{url}" unless File.file?(local)
    end
  end
end
Dir.glob(File.join(root, 'assets', '**', '*.css')).each do |file|
  File.read(file).scan(/url\(([^)]+)\)/).flatten.each do |value|
    url = value.strip.gsub(/\A['"]|['"]\z/, '')
    next if url.start_with?('data:', '#')
    uri = URI.parse(url.gsub(' ', '%20'))
    if uri.host
      errors << "#{file}: external stylesheet dependency #{url}"
    else
      local = File.expand_path(URI::DEFAULT_PARSER.unescape(uri.path), File.dirname(file))
      errors << "#{file}: missing stylesheet dependency #{url}" unless File.file?(local)
    end
  end
end
abort(errors.join("\n")) unless errors.empty?
puts "PASS: theme scripts, styles, and fonts resolve locally. Remaining service scripts: #{external.keys.sort.join(', ')}"
