# frozen_string_literal: true

require_relative "remote_content"

module BeejBlog
  class CommentCounts < Jekyll::Generator
    priority :low

    def self.rank(posts, mapping, issues, site_title, title_on_all_pages)
      issues = issues.reject { |issue| issue.key?("pull_request") }
      posts.filter_map do |post|
        number = mapping[post.relative_path]
        title = CGI.unescapeHTML((post.data["share-title"] || post.data["title"]).to_s.gsub(/<[^>]*>/, ""))
        title += " | #{site_title}" if title_on_all_pages && site_title && title != site_title
        issue = if number
                  issues.find { |item| item["number"] == number.to_i }
                else
                  issues.select { |item| item["title"] == title }.min_by { |item| item["number"] }
                end
        count = issue ? issue["comments"].to_i : 0
        next if count.zero?
        { "post" => post, "count" => count }
      end.sort_by { |row| [-row["count"], -row["post"].date.to_i, row["post"].url] }
    end

    def generate(site)
      repository = site.config.dig("utterances", "repository")
      return unless repository
      content = site.instance_variable_get(:@beej_remote_content) || RemoteContent.new(site)
      site.instance_variable_set(:@beej_remote_content, content)
      issues = []
      page = 1
      loop do
        batch = JSON.parse(content.fetch("https://api.github.com/repos/#{repository}/issues?state=all&per_page=100&page=#{page}"))
        raise Jekyll::Errors::FatalException, "Expected a GitHub issue list" unless batch.is_a?(Array)
        issues.concat(batch)
        break if batch.length < 100
        page += 1
      end
      site.data["posts_by_comments"] = self.class.rank(
        site.posts.docs, site.data["utterances"] || {}, issues,
        site.config["title"], site.config["title-on-all-pages"]
      )
    end
  end
end
