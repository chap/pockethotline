class TwilioController < ApplicationController
  layout false

  def start
    @users_available_to_take_calls = User.available_to_take_calls
    @call = Call.create_from_twilio_params(params)
    @call.delay(:run_at => 1.minute.from_now).redirect_if_not_answered(no_answer_or_completed_url(:CallSid => @call.twilio_id))
    if @call.caller.blocked?
      render :action => :blocked
    elsif @call.caller.over_caller?
      render :action => :over_caller
    else
      dial_operators if @users_available_to_take_calls.any?
    end
  end

  def operator_answer
    @call = Call.find(params[:call_id])
    @user = User.find(params[:user_id])
    # press 1 to be connected
    # press 9 to be taken off call
  end

  def operator_response
    @call = Call.find(params[:call_id])
    @user = User.find(params[:user_id])
    @connect = params[:Digits] == '1'
    @off_call = params[:Digits] == '0'

    if @connect
      if @call.unanswered?
        @call.update_attributes(:operator_id => params[:user_id], :answered_at => Time.now)
      else
        @already_answered = true
      end
    elsif @off_call
      @user.toggle_status(:off)
    end
  end

  def no_answer_or_completed
    @call = Call.find_by_twilio_id(params[:CallSid]) if params[:CallSid]
    if params[:DialCallStatus] == 'completed' || params[:DialCallStatus] == 'answered'
      if params[:CallSid] && params[:RecordingUrl] && params[:RecordingDuration]
        @call.update_attributes(
          :twilio_recording_url => params[:RecordingUrl],
          :length => params[:RecordingDuration],
          :ended_at => Time.now
        )
        @call.assign_sponsors
        @call.reload
        if Rails.configuration.x.hotline.sms_number.present? && @call.sms_caller_for_review_at.blank? && @call.length > 90
          @call.request_caller_review
        end
      end
      render :text => '<?xml version="1.0" encoding="UTF-8"?><Response></Response>'
    else
      # no answer
      render :action => :no_answer
    end
  end

  def caller_hangup
  end

  def caller_review
    @call = Call.find_by_twilio_id(params[:CallSid])
    if params[:caller_review_id]
      @caller_review = Caller_review.find(params[:caller_review_id])
      @caller_review.update_attributes(
        :comments_recording_url => params[:RecordingUrl], 
        :comments_recording_duration => params[:RecordingDuration]
      )
    else
      @caller_review = Caller_review.create(:call_id => @call.id, :keypad_rating => params[:Digits])
    end
  end

  private
  def dial_operators
    User.available_to_take_calls.each do |user|
      c = TWILIO.calls.create(
        :from => Rails.configuration.x.hotline.number,
        :to => user.phone,
        :url => twilio_operator_answer_url(:call_id => @call.id, :user_id => user.id)
      )
      OutgoingCall.create(
        :operator => user,
        :call => @call,
        :started_at => Time.now,
        :twilio_id => c.sid
      )
    end
  end
end
