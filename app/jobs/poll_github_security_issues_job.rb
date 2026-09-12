require "net/http"
require "uri"

class PollGithubSecurityIssuesJob < ApplicationJob
  queue_as :default
  GITHUB_API = "https://api.github.com"

  def perform
    validate_configuration!
    Company.where.not(github_repository: [nil, ""]).find_each do |company|
      fetch_security_issues(company.github_repository).each { |issue| post_issue(company.github_repository, issue) }
    rescue StandardError => error
      Rails.logger.error("GitHub issue import failed for #{company.github_repository}: #{error.message}")
      raise
    end
  end

  private

  def validate_configuration!
    ENV.fetch("GITHUB_PAT")
    ENV.fetch("INTERNAL_INGEST_TOKEN")
    ENV.fetch("APP_URL")
  end

  def fetch_security_issues(repository)
    issues = []
    uri = URI("#{GITHUB_API}/repos/#{repository}/issues?state=all&labels=security&per_page=100")
    loop do
      response = github_get(uri)
      issues.concat(JSON.parse(response.body).reject { |issue| issue.key?("pull_request") })
      next_url = next_page_url(response["link"])
      break unless next_url
      uri = URI(next_url)
    end
    issues
  end

  def github_get(uri)
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{ENV.fetch('GITHUB_PAT')}"
    request["Accept"] = "application/vnd.github+json"
    request["X-GitHub-Api-Version"] = "2022-11-28"
    request["User-Agent"] = "Triagent-GitHub-Importer"
    response = request_uri(uri, request)
    raise "GitHub API returned #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
    response
  end

  def next_page_url(link_header)
    return if link_header.blank?
    link_header.split(",").find { |link| link.include?('rel="next"') }&.match(/<([^>]+)>/)&.captures&.first
  end

  def post_issue(repository, issue)
    base_url = ENV.fetch("APP_URL").delete_suffix("/")
    uri = URI("#{base_url}/api/internal/github_issues")
    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json", "X-Internal-Token" => ENV.fetch("INTERNAL_INGEST_TOKEN"))
    request.body = { repository: repository, issue: issue.slice("html_url", "title", "body", "created_at", "updated_at", "state", "labels") }.to_json
    response = request_uri(uri, request)
    raise "Internal import returned #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
  end

  def request_uri(uri, request)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 30) { |http| http.request(request) }
  end
end
