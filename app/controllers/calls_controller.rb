class CallsController < ApplicationController
  before_filter :require_login
  # before_filter :require_admin

  def index
    @user = find_user
    if current_user.admin? && !@user
      @calls = Call
    else
      @user = current_user
      @calls = @user.calls
    end

    @calls = @calls.includes(:caller).page(params[:page])
    date = params[:date].to_date rescue nil
    @calls = @calls.where('created_at >= ? and created_at <= ?', date.beginning_of_day, date.end_of_day) if date

  end

  private
  def find_user
    if params[:user_id]
      user = current_user
      if current_user.admin? && params[:user_id] != 'current'
        user = User.find(params[:user_id])
      end
      user
    end
  end
end
