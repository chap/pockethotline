desc "This task is called every hour (on :00) by the Heroku Scheduler add-on"
task :oncall_scheduler => :environment do
  begin
    OncallSchedule.hourly_on_offs
  rescue Exception => e
    Airbrake.notify(e)
    raise # to show error in console
  end
end
