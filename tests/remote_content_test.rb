# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "jekyll"
require_relative "../_plugins/remote_content"
require_relative "../_plugins/comment_counts"
require_relative "../_plugins/local_images"

class RemoteContentTest < Minitest::Test
  def test_comment_ranking_uses_issue_mapping_and_title_fallback_and_excludes_empty_posts
    post_type = Struct.new(:relative_path, :data, :date, :url)
    posts = [
      post_type.new('_posts/first.md', { 'title' => 'Renamed post' }, Time.at(10), '/first/'),
      post_type.new('_posts/second.md', { 'title' => 'Second' }, Time.at(20), '/second/'),
      post_type.new('_posts/empty.md', { 'title' => 'Empty' }, Time.at(30), '/empty/')
    ]
    issues = [
      { 'number' => 1, 'title' => 'Original title', 'comments' => 10 },
      { 'number' => 2, 'title' => 'Second | Blog', 'comments' => 10 },
      { 'number' => 3, 'title' => 'Empty | Blog', 'comments' => 0 },
      { 'number' => 4, 'title' => 'Empty | Blog', 'comments' => 100, 'pull_request' => {} },
      { 'number' => 5, 'title' => 'Archived | Blog', 'comments' => 999 }
    ]
    rows = BeejBlog::CommentCounts.rank(posts, { '_posts/first.md' => 1 }, issues, 'Blog', true)
    assert_equal ['/second/', '/first/'], rows.map { |row| row['post'].url }
    assert_equal [10, 10], rows.map { |row| row['count'] }
  end

  URL = "https://raw.githubusercontent.com/example/project/main/docs/README.md"

  def setup
    @directory = Dir.mktmpdir("beej-remote-test")
    @site = Jekyll::Site.new(Jekyll.configuration(
      "source" => @directory, "destination" => File.join(@directory, "_site"),
      "markdown" => "kramdown", "kramdown" => { "input" => "GFM" }, "plugins" => []
    ))
    @content = BeejBlog::RemoteContent.new(@site)
    @site.instance_variable_set(:@beej_remote_content, @content)
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def render(text)
    Liquid::Template.parse(text, error_mode: :strict).render!(
      {}, registers: { site: @site }, strict_variables: false
    )
  end

  def test_multiple_embeds_are_static_and_duplicate_urls_are_fetched_once
    calls = 0
    @content.stub(:request, ->(_url) { calls += 1; "## Imported\n\n{{ untouched }}" }) do
      html = render("Before\n{% remote_markdown \"#{URL}\" %}\nBetween\n{% remote_markdown '#{URL}' %}\nAfter")
      assert_equal 2, html.scan('<h2 id="imported">Imported</h2>').length
      assert_includes html, "{{ untouched }}"
      assert_includes html, "Between"
      refute_includes html, "<script"
    end
    assert_equal 1, calls
  end

  def test_relative_links_and_images_are_resolved_without_changing_external_urls
    html = @content.markdown("[Guide](guide.md) ![Picture](../images/photo.png) [Anchor](#install) [External](https://example.org/) <img src=\"/logo.png\">", URL)
    assert_includes html, 'href="https://github.com/example/project/blob/main/docs/guide.md"'
    assert_includes html, 'src="https://raw.githubusercontent.com/example/project/main/images/photo.png"'
    assert_includes html, 'href="#install"'
    assert_includes html, 'href="https://example.org/"'
    assert_includes html, 'src="https://raw.githubusercontent.com/example/project/main/logo.png"'
  end

  def test_generic_url_resolution
    html = @content.markdown("[Guide](guide.md) ![Picture](picture.png)", "https://example.org/docs/readme.md")
    assert_includes html, 'href="https://example.org/docs/guide.md"'
    assert_includes html, 'src="https://example.org/docs/picture.png"'
  end

  def test_snapshot_fallback_and_fresh_fetch_on_next_build
    @content.stub(:request, "First version") { assert_equal "First version", @content.fetch(URL) }
    next_build = BeejBlog::RemoteContent.new(@site)
    next_build.stub(:request, ->(_url) { raise IOError, "offline" }) do
      assert_equal "First version", next_build.fetch(URL)
    end
    latest_build = BeejBlog::RemoteContent.new(@site)
    latest_build.stub(:request, "Latest version") { assert_equal "Latest version", latest_build.fetch(URL) }
  end

  def test_missing_snapshot_fails_instead_of_publishing_empty_content
    @content.stub(:request, ->(_url) { raise IOError, "offline" }) do
      assert_raises(Jekyll::Errors::FatalException) { @content.fetch(URL) }
    end
  end

  def test_unchanged_download_does_not_touch_snapshot_or_trigger_file_watchers
    @content.stub(:request, "Same version") { @content.fetch(URL) }
    path = Dir.glob(File.join(@directory, "_remote_content", "*.json")).first
    saved_time = Time.at(1_700_000_000)
    File.utime(saved_time, saved_time, path)
    next_build = BeejBlog::RemoteContent.new(@site)
    next_build.stub(:request, "Same version") { next_build.fetch(URL) }
    assert_equal saved_time, File.mtime(path)
  end

  def test_gist_renders_markdown_code_and_attachment_links
    files = {
      "readme.md" => { "filename" => "readme.md", "raw_url" => URL, "content" => "## Instructions" },
      "sample.ps1" => { "filename" => "sample.ps1", "raw_url" => "https://example.org/sample.ps1", "content" => "Write-Host \"<safe>\"\nWrite-Host 'second line'\n" },
      "shortcut.lnk" => { "filename" => "shortcut.lnk", "raw_url" => "https://example.org/shortcut.lnk", "content" => "binary" }
    }
    @content.stub(:request, JSON.generate({ "files" => files })) do
      html = render('{% remote_gist "abcdef1234" %}')
      assert_includes html, "Instructions</h2>"
      assert_includes html, "highlighter-rouge"
      assert_match(/<span class="[^"]+">/, html)
      assert_includes html, "&lt;safe&gt;"
      assert_includes html, 'href="https://example.org/shortcut.lnk"'
      refute_includes html, "<script"
      full_embed = Nokogiri::HTML.fragment(html)
      assert_equal 3, full_embed.css('h3.remote-gist-file-heading a.remote-gist-source').length
      assert_equal 'https://gist.github.com/abcdef1234#file-readme-md', full_embed.at_css('h3 a.remote-gist-source')['href']
      assert_equal ['BeejBlogGistSource'], full_embed.css('a.remote-gist-source').map { |link| link['target'] }.uniq
      assert_empty full_embed.css('p.remote-gist-source-block')
      selected = render('{% remote_gist "abcdef1234" "sample.ps1" %}')
      selected_embed = Nokogiri::HTML.fragment(selected)
      lines = selected_embed.css('.gist-code-line')
      assert_equal 2, lines.length
      assert_equal %w[1 2], selected_embed.css('.gist-line-number').map { |link| link['data-line-number'] }
      lines.each do |line|
        link = line.at_css('.gist-line-number')
        assert_equal "##{line['id']}", link['href']
        assert_equal '', link.text
      end
      assert_equal files['sample.ps1']['content'], selected_embed.at_css('pre code').text
      assert_equal 'sample.ps1 source gist', selected_embed.at_css('h3').text
      assert_equal 'https://gist.github.com/abcdef1234#file-sample-ps1', selected_embed.at_css('h3 a.remote-gist-source')['href']
      assert_empty selected_embed.css('p.remote-gist-source-block')
      refute_includes selected, "readme.md</h3>"
    end
  end

  def test_gist_file_source_anchors_match_github_filename_format
    names = ['host_driver.ps1', '.gitignore', 'Launch Windows Sandbox with Winget Enabled (via LogonCommand).url']
    files = names.to_h { |name| [name, { 'filename' => name, 'raw_url' => URL, 'content' => 'example' }] }
    @content.stub(:request, JSON.generate({ 'files' => files })) do
      fragment = Nokogiri::HTML.fragment(render('{% remote_gist "abcdef1234" %}'))
      anchors = fragment.css('a.remote-gist-source').map { |link| link['href'].split('#').last }
      assert_equal ['file-gitignore', 'file-launch-windows-sandbox-with-winget-enabled-via-logoncommand-url', 'file-host_driver-ps1'], anchors
    end
  end

  def test_multiline_tokens_and_repeated_embeds_keep_source_and_unique_anchors
    source = "/* multiline\ncomment */\n\nconst value = 1;"
    file = { 'filename' => 'sample.js', 'raw_url' => URL, 'content' => source }
    @content.stub(:request, JSON.generate({ 'files' => { 'sample.js' => file } })) do
      html = render('{% remote_gist "abcdef1234" %}{% remote_gist "abcdef1234" %}')
      fragment = Nokogiri::HTML.fragment(html)
      assert_equal [source, source], fragment.css('pre code').map(&:text)
      ids = fragment.css('.gist-code-line').map { |line| line['id'] }
      assert_equal 8, ids.length
      assert_equal ids.uniq, ids
      assert_equal %w[1 2 3 4 1 2 3 4], fragment.css('.gist-line-number').map { |link| link['data-line-number'] }
    end
  end

  def test_truncated_gist_fetches_the_complete_file
    file = { "filename" => "script.ps1", "raw_url" => "https://example.org/script.ps1", "content" => "partial", "truncated" => true }
    @content.stub(:request, ->(url) { url.include?("api.github.com") ? JSON.generate({ "files" => { "script.ps1" => file } }) : "Write-Host 'complete'" }) do
      html = render('{% remote_gist "abcdef1234" %}')
      assert_includes html, "complete"
      refute_includes html, "partial"
    end
  end

  def test_invalid_tag_arguments_are_rejected
    assert_raises(ArgumentError) { Liquid::Template.parse('{% remote_markdown unquoted %}') }
    assert_raises(ArgumentError) { Liquid::Template.parse('{% remote_markdown "a" "b" %}') }
    assert_raises(ArgumentError) { render('{% remote_gist "not-an-id" %}') }
  end

  def test_only_https_is_accepted
    assert_raises(ArgumentError) { @content.request("http://example.org/readme.md") }
    assert_raises(ArgumentError) { @content.request("file:///etc/passwd") }
  end

  def test_image_localization_rewrites_images_and_fullsize_links_using_saved_mapping
    path = File.join(@directory, 'images', 'saved.png')
    FileUtils.mkdir_p(File.dirname(path))
    File.binwrite(path, "\x89PNG\r\n\x1a\n".b)
    @site.data['local_images'] = { 'https://example.org/image.png' => '/images/saved.png' }
    images = BeejBlog::LocalImages.new(@site)
    document = Struct.new(:output, :output_ext, :date).new('<html><body><a href="https://example.org/image.png"><img src="https://example.org/image.png"></a></body></html>', '.html', Time.now)
    images.stub(:download, ->(*) { raise 'Existing images must not be fetched again' }) { images.render(document) }
    rendered = Nokogiri::HTML(document.output)
    assert_equal '/images/saved.png', rendered.at_css('img')['src']
    assert_equal '/images/saved.png', rendered.at_css('a')['href']
  end

  def test_new_imported_image_is_saved_and_registered_for_static_output
    images = BeejBlog::LocalImages.new(@site)
    document = Struct.new(:date).new(Time.utc(2017))
    images.stub(:download, ["\x89PNG\r\n\x1a\n".b, '.png']) do
      local = images.localize('https://example.org/new.png', document)
      assert_match(%r{\A/images/uploads/2017/remote-}, local)
      assert File.file?(File.join(@directory, local.delete_prefix('/')))
      assert @site.static_files.any? { |file| file.relative_path.delete_prefix('/') == local.delete_prefix('/') }
      images.save
      assert File.file?(File.join(@directory, '_data', 'local_images.json'))
    end
    assert_raises(IOError) { BeejBlog::LocalImages.extension('<html>404</html>') }
  end

  def test_unavailable_new_image_renders_a_local_placeholder
    images = BeejBlog::LocalImages.new(@site)
    images.stub(:download, ->(*) { raise IOError, '404' }) do
      assert_equal '/assets/img/image-unavailable.svg', images.localize('https://example.org/missing.png', nil)
    end
  end

  def test_absolute_images_on_our_own_preview_host_are_not_downloaded
    @site.config['url'] = 'http://localhost:4100'
    path = File.join(@directory, 'images', 'local photo.png')
    FileUtils.mkdir_p(File.dirname(path))
    File.binwrite(path, 'saved image')
    images = BeejBlog::LocalImages.new(@site)
    images.stub(:download, ->(*) { raise 'Local images must not use the network' }) do
      assert_equal '/images/local photo.png', images.localize('http://localhost:4100/images/local%20photo.png', nil)
    end
    @site.config['url'] = 'https://Next-Technologies.com'
    images.stub(:download, ->(*) { raise 'Hostname matching must ignore case' }) do
      assert_equal '/images/local photo.png', images.localize('https://next-technologies.com/images/local%20photo.png', nil)
    end
  end
end
