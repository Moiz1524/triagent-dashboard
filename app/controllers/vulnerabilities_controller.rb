class VulnerabilitiesController < ApplicationController
  before_action :require_login

  def index
    @vulnerabilities = accessible_vulnerabilities.includes(:assigned_reviewers).where(archived: false).order(created_at: :desc)
    @vulnerabilities = @vulnerabilities.where(severity: params[:severity]) if params[:severity].present?
    @vulnerabilities = @vulnerabilities.where(status: params[:status]) if params[:status].present?
    @vulnerabilities = @vulnerabilities.where(assessment_category: params[:assessment_category]) if params[:assessment_category].present?
    if params[:query].present?
      query = "%#{ActiveRecord::Base.sanitize_sql_like(params[:query])}%"
      @vulnerabilities = @vulnerabilities.where("humanized_slug_id ILIKE :q OR summary ILIKE :q OR possible_location ILIKE :q", q: query)
    end
    all = accessible_vulnerabilities.where(archived: false)
    @total_findings = all.count
    @severity_stats = all.group(:severity).count
    @dependency_stats = all.pluck(:external_libs_details).flatten.filter_map { |lib| lib["name"].presence || lib[:name].presence }.tally.sort_by { |_, n| -n }.first(8)
  end

  def show
    @vulnerability = accessible_vulnerabilities.includes(:assigned_reviewers).find(params[:id])
  end

  private
  def accessible_vulnerabilities
    return Vulnerability.none unless current_company
    scope = current_company.vulnerabilities
    current_user.super_admin? ? scope : scope.joins(:assignments).where(assignments: { user_id: current_user.id }).distinct
  end
end
