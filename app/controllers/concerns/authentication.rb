module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :current_company
  end

  def current_user
    return @current_user if defined?(@current_user)
    token = cookies.encrypted[:auth_token] || request.authorization.to_s.delete_prefix("Bearer ")
    claims = JwtToken.decode(token)
    @current_user = User.find_by(id: claims&.[](:user_id), company_id: claims&.[](:company_id))
  end

  def current_company = current_user&.company

  def require_login
    return if current_user
    respond_to do |format|
      format.html { redirect_to login_path, alert: "Please sign in to continue." }
      format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
    end
  end

  def require_super_admin
    return if current_user&.super_admin?
    render json: { error: "Super admin access is required" }, status: :forbidden
  end
end
