class Api::V1::BaseController < ApplicationController
  skip_forgery_protection
  before_action :require_login
  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end

  private
  def accessible_vulnerabilities
    scope = current_company.vulnerabilities
    current_user.super_admin? ? scope : scope.joins(:assignments).where(assignments: { user_id: current_user.id }).distinct
  end
end
