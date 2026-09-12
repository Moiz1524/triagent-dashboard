class Api::V1::VulnerabilitiesController < Api::V1::BaseController
  before_action :require_super_admin, only: %i[create update archive]
  before_action :set_vulnerability, only: %i[update archive]

  def index
    render json: accessible_vulnerabilities.where(archived: false).order(created_at: :desc).map { |v| json_vulnerability(v) }
  end

  def create
    vulnerability = current_company.vulnerabilities.new(vulnerability_params)
    assign_reviewers(vulnerability)
    if vulnerability.save
      render json: json_vulnerability(vulnerability), status: :created
    else
      render json: { errors: vulnerability.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    assign_reviewers(@vulnerability)
    if @vulnerability.update(vulnerability_params)
      render json: json_vulnerability(@vulnerability)
    else
      render json: { errors: @vulnerability.errors.full_messages }, status: :unprocessable_content
    end
  end

  def archive
    @vulnerability.update!(archived: true)
    head :no_content
  end

  private
  def set_vulnerability = @vulnerability = current_company.vulnerabilities.find(params[:id])
  def vulnerability_params
    params.permit(:humanized_slug_id, :assessment_category, :possible_location, :summary, :severity, :remediation_link, :seen_at, :status, :initial_report, :github_issue_url, :full_assessment, external_libs_details: [:name, :repo_link])
  end
  def assign_reviewers(vulnerability)
    return unless params.key?(:assigned_reviewer_ids)
    ids = Array(params[:assigned_reviewer_ids]).map(&:to_i)
    users = current_company.users.reviewer.where(id: ids)
    vulnerability.assigned_reviewers = users
  end
  def json_vulnerability(v)
    v.as_json(only: %i[id humanized_slug_id assessment_category possible_location summary severity remediation_link seen_at external_libs_details status initial_report github_issue_url archived created_at updated_at]).merge(
      assigned_reviewers: v.assigned_reviewers.select(:id, :full_name, :email), full_assessment_url: (url_for(v.full_assessment) if v.full_assessment.attached?)
    )
  end
end
