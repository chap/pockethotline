# What
Pockethotline is a rails app that allows you to setup a "distributed hotline". This allows you to have a hotline number that is published and operators signup with their personal numbers. When someone calls the main number the operators will be called (depending on their on-call status) and connected to the main caller.

It was originally conceived as a business by Scott McGee and Chap Ambrose at the Austin Center for Design in the winter of 2011.

The software was open-sourced January 2014.

# How much does it cost to run a hotline?

#### Hosting Costs
The minimum hosting costs are about $35 a month. This is because a background worker dyno is required. (Assuming you're using [Heroku](http://heroku.com) for hosting).

#### Phone Costs
[Twilio](http://twilio.com) phone numbers cost $1/month for local numbers and $2/month for toll-free.

Twilio charges you by minutes used, $0.03/minute for local and $0.05/minute for toll-free. 

*Twilio's published rates are $0.01 / $0.03 but that is only for the incoming call, you also have to add another $0.02 to each call because of the outgoing connection to the operators.*

# Basic Setup

##1. Setup accounts on:
* [Twilio.com](http://twilio.com)
* [Heroku.com](http://heroku.com) (or other rails capable host)

##2. Get a phone number on Twilio
Start with the free trial number or purchase another toll-free or local number.

##3. Take note of your phone number and API credentials AccountSID and AuthToken 
Find them under "Account Settings"

##4. Clone the repository  
```$ git clone git@github.com:chap/pockethotline.git```

##5. Edit config file at ```/config/initializers/hotline.rb``` 
You must edit values for:

* config.x.hotline.name
* config.x.hotline.domain
* config.x.hotline.organizer
* config.x.hotline.organizer_email 
* config.x.hotline.number

##6. Save changes  
```$ git commit config/initializers/hotline.rb -m "updated config"```

##7. Create an app on heroku  
```$ heroku create myhotline-name```

##8. Enable Sendgrid add-on for sending email
```$ heroku addons:add sendgrid```
  
Any SMTP provider should work. If you don't use Sendgrid, manually update settings at ```config/initializers/smtp_settings.rb```

##9. Push application to heroku  
```$ git push heroku master```

##10. Create database tables  
```$ heroku run rake db:schema:load```

##11. Scale up worker dyno (required for background tasks)  
```$ heroku ps:scale worker=1```

##12. Add TWILIO_AUTH_TOKEN ENV variable to heroku config
Use Twilio API credentials from step 3.
```$ heroku config:set TWILIO_AUTH_TOKEN=XXXXXXXXXXXXXX```

##13. Add SESSION_SECRET ENV variables to heroku config
First run  
```$ heroku run rake secret```

Copy the output and use it here:  
```$ heroku config:set SESSION_SECRET=XXXXXXXXXXXXXX```

##14. Setup the on-call scheduler
1. ```$ heroku addons:add scheduler```
2. ```$ heroku addons:open scheduler```
3. Click "Add Job"
4. In the left-most field enter "rake oncall_scheduler"
5. Change frequency to "Hourly"
6. Set next run to "XX:00" (The XX will depend on the current time.)
7. Click "Save"


##15. Create yourself an account (edit these values)  
```
  $ heroku run rails console
  $ u = User.new(
    :name => 'my name', 
    :email => 'myemail@email.com', 
    :phone => '215-359-5228', 
    :password => 'setyourpasswordhere'
    )
    u.admin = true
    u.on_call = true
    u.save!
```

##16. Login to your account
```$ heroku open```

##17. Update Twilio with your app's domain
* Click on 'Numbers' in the nav bar
* Click on your phone number
* Change the 'Voice Request URL' to ```https://myhotline-name.herokuapp.com/twilio/start```
* Set request method to [POST]

##18. Call the hotline and see if it's working!
* Don't call from the same number that you added for yourself
* If you're using your free demo Twilio account you'll hear a pre-roll message. That will go away when you upgrade your account.
* Your call should be connected after the greeting message is used.
* If calling via Gtalk fails to connect, try a real land or cell line.

##19. Yeah!

===

#Advanced Setup of Hotline Supporters

##1. Create an account on Stripe.com

##2. Set Stripe publishable key in config
Uncomment (remove leading '#') and edit values in  ```/config/hotline.rb```

* config.x.stripe.publishable_key

##3. Add Stripe API key
```$ heroku config:set STRIPE_SECRET_KEY=XXXXXXXXXXXXXX```

##4. Save changes and deploy
```$ git commit /config/initializers/hotline.rb -m "add stripe details"```
```$ git push heroku```
  
##5. Visit suporters page

https://.../supporters/new  

Stripe requires SSL to be enabled, if you're using your default heroku domain you will seemlessly piggy-back on the wildcard certificate at *.herokuapp.com.

If you want to use a different domain you may have to purchase and setup your own certificate. 

===

#Advanced Allow Supporters to Upload Images

##1. Add your S3 bucket name to /config/hotline.rb

##2. Add S3 access_key_id and secret_access_key
```$ heroku config:set S3_ACCESS_KEY_ID=XXXXXXXXXXXXXX S3_SECRET_ACCESS_KEY=XXXXXXXXXXXXXX```

===

#Forward unanswered calls, change recordings, Twitter integration, etc

Look at all the options in /config/hotline.rb
