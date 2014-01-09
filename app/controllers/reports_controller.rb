class ReportsController < ApplicationController
	before_filter :require_login
  before_filter :require_admin

  def index
  	@users = User.find([230, 237, 222, 234, 231, 232])
  	@starts_at = params[:starts_at].to_date rescue Time.now - 1.week
  	@ends_at   = params[:ends_at].to_date rescue Time.now + 1.week

  	@starts_at = @starts_at.beginning_of_day
  	@ends_at   = @ends_at.end_of_day
  end
end
