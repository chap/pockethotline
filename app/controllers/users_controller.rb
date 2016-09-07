class UsersController < ApplicationController
  before_filter :require_login, :except => [:set_password, :save_password, :apply, :apply_thanks, :create, :unsubscribe]
  before_filter :require_admin, :only => [:index, :new, :destroy, :show, :approve]

  def index
    @users = User.order('name').active.includes(:oncall_schedules)
    @users = @users.paginate(:page => params[:page])
  end

  def edit
    @user = find_user
  end

  def show
    @user = find_user

    render :action => :edit
  end

  def edit_on_call_status
    @user = find_user
  end

  def toggle_status
    @user = find_user

    if !@user.toggle_status
      head :bad_request
    end
  end

  def set_password
    @user = User.find_by_token(params[:token])
    unless @user
      flash.now.alert = "Invalid link"
      redirect_to root_url
    end
  end

  def save_password
    @user = User.find_by_token(params[:token])
    if @user && @user.update_attributes(params[:user].slice(:password, :password_confirmation, :phone))
      @user.reload
      login(@user)
      redirect_to dashboard_url
    else
      redirect_to set_password_url(:token => params[:token]), :notice => "Something went wrong, try again."
    end
  end

  def new
    @user = User.new
  end

  def apply
    @user = User.new
  end

  def create
    if logged_in? && current_user.admin?
      admin_creating_users
    else
      user_applying
    end
  end

  def update
    @user = find_user
    @user.user_updating_themselves = true
    if @user.update_attributes(params[:user].slice(:name, :email, :phone, :twitter, :bio, :newsletter_emails, :schedule_emails, :volunteers_first_availability_emails))
      if params[:user][:on_call] == '1'
        @user.toggle_status(:on)
      elsif params[:user][:on_call] == '0'
        @user.toggle_status(:off)
      end
      if current_user.admin?
        @user.admin = params[:user][:admin] if params[:user][:admin]
        @user.save
      end
      redirect_to edit_user_url(@user), :notice => "User updated"
    else
      render :action => "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.admin_creating_user = true
    @user.update_attributes!(:deleted_at => Time.now)

    redirect_to users_url, :notice => "User deleted"
  end

  def approve
    @user = User.find(params[:id])
    @user.update_attribute(:pending_approval, false)
    UserMailer.welcome(@user).deliver
    redirect_to edit_user_path(@user), :notice => "User approved."
  end

  def unsubscribe
    @user = User.find_by_token!(params[:token])
    update = {
      :newsletter_emails => false,
      :schedule_emails => false,
      :volunteers_first_availability_emails => false,
      :user_updating_themselves => true
    }
    update.delete(:newsletter_emails) if (params[:only] == 'schedule' || params[:only] == 'volunteers_first_availability_emails')
    update.delete(:schedule_emails) if (params[:only] == 'newsletter' || params[:only] == 'volunteers_first_availability_emails')
    update.delete(:volunteers_first_availability_emails) if (params[:only] == 'schedule' || params[:only] == 'newsletter')
    @user.update_attributes!(update)
    redirect_to login_url, :notice => "#{@user.email} has been unsubscribed from #{params[:only] ? params[:only].humanize.downcase : 'all emails'}. To change this login and go to 'My Info'."
  end

  private
  def find_user
    user = current_user
    if current_user.admin? && params[:id] != 'current'
      user = User.find(params[:id])
    end
    user
  end

  def admin_creating_users
    @user = User.new(params[:user].slice(:name, :email))
    @user.admin_creating_user = true

    if @user.save
      UserMailer.welcome(@user).deliver
      notice = "Invite email sent to #{@user.email}"
      redirect_to({:action => "index"}, {:notice => notice})
    else
      render :action => "new"
    end
  end

  def user_applying
    @user = User.new(params[:user].slice(:name, :email, :phone, :twitter, :bio))
    @user.pending_approval = true
    @user.user_applying = true

    if @user.save
      UserMailer.user_applied(@user).deliver
      redirect_to(apply_thanks_users_url)
    else
      render :action => "apply"
    end
  end
end
