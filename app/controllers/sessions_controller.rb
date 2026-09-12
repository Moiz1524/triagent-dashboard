class SessionsController < ApplicationController
  def new
    redirect_to root_path if current_user
  end

  def create
    user = User.find_by(email: params[:email].to_s.downcase)
    if user&.authenticate(params[:password])
      cookies.encrypted[:auth_token] = { value: JwtToken.encode({ user_id: user.id, company_id: user.company_id }), httponly: true, same_site: :lax, secure: Rails.env.production? }
      redirect_to root_path, notice: "Welcome back, #{user.full_name}."
    else
      flash.now[:alert] = "Incorrect email or password."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to login_path, notice: "You have been signed out."
  end
end
