class SessionsController < ApplicationController
  def new
    logout
  end

  def request_password_reset
    user = User.find_by_email(params[:email])
    if user
      UserMailer.forgot_password(user).deliver
      redirect_to login_url, :notice => "An email has been sent to #{params[:email]} with instructions to reset your password."
    else
      flash.now.alert = "No user was found with that email"
      render "forgot_password"
    end
  end

  def create
    user = User.authenticate(params[:session][:email], params[:session][:password])
    if user
      # login user
      login(user)
      logger.info "[SessionsController:#{self.id}] User:#{user.id} logged in, #{Time.zone.now}"
      url = session[:return_to] ? session[:return_to] : root_url
      url = root_url if url.include?('/login')
      session[:return_to] = nil
      redirect_to dashboard_url, :notice => "Logged in!"
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    logout
    redirect_to root_url, :notice => "Logged out!"
  end
end
