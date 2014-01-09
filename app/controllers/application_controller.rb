class ApplicationController < ActionController::Base
  include UrlHelper
  protect_from_forgery
  before_filter :set_time_zone

  private

  def set_time_zone
    Time.zone = Rails.configuration.time_zone
  end

  def require_login
    unless logged_in?
      store_location
      redirect_to(login_url, :notice => "Try logging in first.")
    end
  end

  def require_admin
    unless admin?
      if logged_in?
        case request.format
        when Mime::XML, Mime::JSON
          render text: '<htmtl><body>You must be an admin of your account to access this.</body></htmtl>', status: 401
        else
          render :text => 'Nope.'
        end
      else
        require_login
      end
    end
  end

  helper_method :current_user, :logged_in?, :admin?, :sponsors_active?, :sponsors_images?

  def current_user
    @current_user ||= User.authenticate_from_cookie(cookies[:remember_me_id], cookies[:remember_me_password_hash])
  end

  def logged_in?
    current_user.present?
  end

  def admin?
    logged_in? && current_user.admin?
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def login(user)
    cookies.permanent[:remember_me_id] = user.id,
    cookies.permanent[:remember_me_password_hash] = user.password_hash
  end

  def logout
    cookies.delete :remember_me_id
    cookies.delete :remember_me_password_hash
  end

  def sponsors_active?
    Rails.configuration.x.stripe.secret_key.present? && Rails.configuration.x.stripe.publishable_key.present?
  end

  def sponsors_images?
    Rails.configuration.x.s3.bucket.present? &&
    Rails.configuration.x.s3.access_key_id.present? &&
    Rails.configuration.x.s3.secret_access_key.present?
  end
end
