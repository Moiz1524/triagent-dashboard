class Api::Internal::GithubIssuesController < ApplicationController
  skip_forgery_protection
  before_action :verify_internal_token

  def create
    company = Company.find_by!(github_repository: params[:repository])
    issue = params.require(:issue).permit(:html_url, :title, :body, :created_at, :updated_at, :state, labels: [:name])
    raise ActionController::BadRequest, "GitHub issue URL is required" if issue[:html_url].blank?
    vulnerability = company.vulnerabilities.find_or_initialize_by(github_issue_url: issue[:html_url])
    vulnerability.assign_attributes(summary: issue[:title], initial_report: issue[:body], seen_at: issue[:created_at], status: :draft)
    vulnerability.save!
    render json: { id: vulnerability.id, humanized_slug_id: vulnerability.humanized_slug_id }, status: :created
  end

  private
  def verify_internal_token
    expected = ENV.fetch("INTERNAL_INGEST_TOKEN", Rails.application.secret_key_base)
    provided = request.headers["X-Internal-Token"].to_s
    return if provided.present? && ActiveSupport::SecurityUtils.secure_compare(provided, expected)
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
