class ReviewsController < ApplicationController
  def new
    @call = Call.find_by_token!(params[:call_token])
    if @call.review
      redirect_to thanks_reviews_url
    else
      @review = @call.build_review
    end
  end

  def create
    @call = Call.find_by_token!(params[:call_token])
    @review = @call.build_review(params[:review])
    @review.call = @call

    if @review.save
      @review.delay.notify
      @review.delay.tweet if @review.should_tweet?
      
      redirect_to thanks_reviews_url
    else
      render action: "new"
    end
  end
end
