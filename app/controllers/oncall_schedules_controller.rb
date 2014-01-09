class OncallSchedulesController < ApplicationController
  before_filter :require_login
  before_filter :require_admin, :only => [:all]

  def all
  end

  def index
    @user = find_user
    @oncall_schedules = []
    @oncall_schedules += @user.oncall_schedules
    (1..7).each do |i|
      unless @oncall_schedules.select {|s| s.wday == i}.any?
        @oncall_schedules << OncallSchedule.new(:wday => i)
      end
    end

    @oncall_schedules = @oncall_schedules.sort_by {|s| s.wday}
  end

  def create
    @user = find_user
    @user.oncall_schedules.destroy_all
    valid_schedule = []
    params[:days].each do |day|
      day = day[1]
      oncall_schedule = {:wday => day[:wday], :start_time => day[:start_time], :end_time => day[:end_time]}
      valid_schedule << oncall_schedule if oncall_schedule[:start_time].present? && oncall_schedule[:end_time].present? && oncall_schedule[:start_time].to_f < oncall_schedule[:end_time].to_f
    end
    if @user.oncall_schedules.create(valid_schedule)
      @user.update_attribute(:schedule_emails, params[:schedule_emails] ? true : false)
      redirect_to user_oncall_schedules_url(params[:user_id]), :notice => "Schedule has been updated."
    else
      redirect_to user_oncall_schedules_url(params[:user_id]), :notice => "There was an error creating your schedule, try again."
    end
  end

  private
  def find_user
    user = current_user
    if current_user.admin? && params[:user_id] != 'current'
      user = User.find(params[:user_id])
    end
    user
  end
end