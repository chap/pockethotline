module ActivitiesHelper
  def timestamp(time)
    content_tag(:abbr, "#{time_ago_in_words(time)} ago", :title => time.iso8601)
  end
end
