class CommentsController < ApplicationController
  before_filter :require_login

  # POST /comments
  # POST /comments.json
  def create
    @activity = Activity.find(params[:activity_id])
    @comment = current_user.comments.new(params[:comment].slice(:body))
    @comment.activity = @activity

    respond_to do |format|
      if @comment.save
        @comment.delay.notify(url_for(activity_url(@activity)))

        format.html { redirect_to @comment, notice: 'Comment was successfully created.' }
        format.json { render json: @comment, status: :created, location: @comment }
        format.js
      else
        format.html { render action: "new" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
        format.js { head :bad_request }
      end
    end
  end
end
