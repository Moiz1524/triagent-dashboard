class Api::V1::SessionsController < ApplicationController
  skip_forgery_protection
  def create
    user = User.find_by(email: params[:email].to_s.downcase)
    return render(json: { error: "Invalid credentials" }, status: :unauthorized) unless user&.authenticate(params[:password])
    render json: { token: JwtToken.encode({ user_id: user.id, company_id: user.company_id }), user: { id: user.id, email: user.email, full_name: user.full_name, role: user.role } }
  end
end
