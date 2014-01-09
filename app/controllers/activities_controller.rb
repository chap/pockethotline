class ActivitiesController < ApplicationController
  before_filter :require_login

  def index
    if params[:user_id]
      @activities = current_user.activities.all
    else
      @activities = Activity.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @activities }
      format.js
    end
  end

  def create
    @activity = Activity.new(params[:activity].slice(:body))
    @activity.user = current_user

    respond_to do |format|
      if @activity.save
        @activity.delay.notify(url_for(activity_url(@activity)))
        format.html { redirect_to @activity, notice: 'Activity was successfully created.' }
        format.json { render json: @activity, status: :created, location: @activity }
        format.js
      else
        format.html { render action: "new" }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
        format.js { head :bad_request }
      end
    end
  end

  def show
    @activity = Activity.includes([:comments => :user]).includes(:user).find(params[:id])
  end
end
