class SponsorsController < ApplicationController
  before_filter :require_sponsors_activation
  before_filter :require_auth_token, :only => [:edit, :update]
  force_ssl :only => [:new, :create]

  def index
    @sponsors = Sponsor.successful
  end

  def new
    @sponsor = Sponsor.new
  end

  def edit
    @sponsor = Sponsor.find_by_token!(params[:id])
  end

  def show
    @sponsor = Sponsor.find_by_token!(params[:id])
  end

  def create
    @sponsor = Sponsor.new(params[:sponsor])

    if @sponsor.save
      customer = Stripe::Customer.create(
        :card => @sponsor.stripe_token,
        :description => "Sponsor:#{@sponsor.id}"
      )

      charge = Stripe::Charge.create(
        :amount => (@sponsor.amount * 100).to_i, # in cents
        :currency => "usd",
        :customer => customer.id,
        :description => "Sponsor:#{@sponsor.id}"
      )

      @sponsor.update_attributes(
        :stripe_customer_id => customer.id,
        :stripe_charge_id => charge.id,
        :successful => charge.paid,
        :fee => (charge.fee / 100),
        :stripe_response => charge,
        :user => current_user,
        :card_type => charge.card.type,
        :last_numbers => charge.card.last4
      )

      if charge.paid
        @sponsor.set_minutes_purchased
        SponsorMailer.receipt(@sponsor).deliver
        redirect_to edit_sponsor_url(@sponsor, :thanks => true, :auth_token => @sponsor.auth_token)
      else
        redirect_to new_sponsor_url, :notice => "Your charge was not successful, please try again."
      end
    else
      render action: "new"
    end
  end

  def update
    @sponsor = Sponsor.find_by_token!(params[:id])

    if @sponsor.update_attributes(params[:sponsor])
      redirect_to sponsor_url(@sponsor, :auth_token => params[:auth_token]), notice: 'Changes saved.'
    else
      render action: "edit"
    end
  end

  private
  def require_sponsors_activation
    redirect_to(root_url, notice: "The hotline organizer has not activated sponsorship.") unless sponsors_active?
  end

  def require_auth_token
    @sponsor = Sponsor.find_by_token!(params[:id])
    redirect_to(@sponsor, notice: "Looks like you don't have permissions to edit this message") unless params[:auth_token] == @sponsor.auth_token
  end
end
