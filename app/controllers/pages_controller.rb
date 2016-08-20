class PagesController < ApplicationController
  before_filter :require_login, :only => [:dashboard]

  def index
    @operators = User.available_to_take_calls(true)
  end

  def volunteer
  end

  def volunteers
    @operators = User.active.have_logged_in.includes(:oncall_schedules)
  end

  def dashboard
    logger.info "[PagesController] User:#{current_user.id}, #{Time.zone.now}"
    @activites = Activity.includes([:comments => :user]).includes(:user).limit(10).order('created_at desc')
    @operators = User.active
    @operators_oncall = User.active.select {|o| o.on_call?}
  end
end
