# frozen_string_literal: true
require_relative 'remote_content'
require 'time'

module BeejBlog
  class StaticComments < Jekyll::Generator
    priority :lowest
    ACCEPT = 'application/vnd.github.full+json'

    def self.normalize(comment, known_ids)
      fragment = Nokogiri::HTML.fragment(comment.fetch('body_html'))
      author = comment.fetch('user').fetch('login')
      profile = comment['user']['html_url']
      published = comment.fetch('created_at')
      first = fragment.at_css('strong')
      imported = first && first.text.match(/\AOriginally posted by (.+) on (\d{4}-\d{2}-\d{2}T[^\s]+)\z/)
      is_imported = imported && comment.fetch('body', '').include?('<!-- disqus-comment:')
      if is_imported
        author, published = imported.captures
        profile = nil
        parent = first.parent
        first.remove
        parent.remove if parent.name == 'p' && parent.text.strip.empty? && parent.element_children.empty?
      end
      fragment.css('a[href]').each do |link|
        id = link['href'][/#issuecomment-(\d+)\z/, 1]
        link['href'] = "#comment-#{id}" if id && known_ids.include?(id.to_i)
        link['rel'] = 'nofollow ugc' unless link['href'].start_with?('#')
      end
      reply_href = nil
      first_paragraph = fragment.element_children.first
      if is_imported && first_paragraph&.name == 'p' && first_paragraph.text.strip == 'Reply to an earlier comment.'
        reply_link = first_paragraph.at_css('a[href]')
        if reply_link && reply_link.text == 'an earlier comment' && first_paragraph.css('a').length == 1
          reply_href = reply_link['href']
          first_paragraph.remove
        end
      end
      { 'id' => comment['id'], 'author' => author, 'profile' => profile,
        'published' => published, 'url' => comment['html_url'], 'reply_href' => reply_href, 'html' => fragment.to_html }
    end

    def self.thread(comments)
      ordered = comments.sort_by { |comment| [comment['published'], comment['id']] }
      by_id = ordered.to_h { |comment| [comment['id'].to_s, comment] }
      parents = {}
      ordered.each do |comment|
        comment['children'] = []
        id = comment['reply_href'].to_s[/\A#comment-(\d+)\z/, 1]
        parents[comment['id'].to_s] = id if id && by_id.key?(id) && id != comment['id'].to_s
      end
      roots = []
      ordered.each do |comment|
        id = comment['id'].to_s
        parent = parents[id]
        seen = { id => true }
        cursor = parent
        while cursor && !seen[cursor]
          seen[cursor] = true
          cursor = parents[cursor]
        end
        parent = nil if cursor # Invalid cyclic relationships stay visible at top level.
        if parent
          comment['parent_id'] = parent
          by_id[parent]['children'] << comment
        else
          comment['parent_id'] = nil
          roots << comment
        end
      end
      roots
    end

    def generate(site)
      repository = site.config.dig('utterances', 'repository')
      return unless repository
      content = site.instance_variable_get(:@beej_remote_content) || RemoteContent.new(site)
      site.instance_variable_set(:@beej_remote_content, content)
      comments = []
      page = 1
      loop do
        url = "https://api.github.com/repos/#{repository}/issues/comments?per_page=100&page=#{page}"
        batch = JSON.parse(content.fetch(url, accept: ACCEPT))
        raise Jekyll::Errors::FatalException, 'Expected GitHub comments list' unless batch.is_a?(Array)
        comments.concat(batch)
        break if batch.length < 100
        page += 1
      end
      grouped = comments.group_by { |comment| comment['issue_url'].split('/').last.to_i }
      site.posts.docs.each do |post|
        number = post.data['utterances_issue_number'] || (site.data['utterances'] || {})[post.relative_path]
        next unless number
        discussion = (grouped[number.to_i] || []).sort_by { |comment| [comment['created_at'], comment['id']] }
        ids = discussion.map { |comment| comment['id'] }
        post.data['static_comments'] = discussion.map { |comment| self.class.normalize(comment, ids) }
          .sort_by { |comment| [comment['published'], comment['id']] }
        post.data['comment_threads'] = self.class.thread(post.data['static_comments'])
        latest = discussion.map { |comment| comment['updated_at'] }.compact.max
        post.data['comment_snapshot_since'] = ((latest ? Time.parse(latest) : Time.now) - 1).utc.iso8601
        post.data['utterances_issue_number'] = number
      end
    end
  end
end
