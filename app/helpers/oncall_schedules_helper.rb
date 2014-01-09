module OncallSchedulesHelper
  def schedule_options_for_select(active)
    options_for_select(oncall_time_options, active)
  end

  def oncall_time_options
    [
      ['Not scheduled...', nil],
      ['Midnight', '0'],
      ['1:00 am', '1'],
      ['2:00 am', '2'],
      ['3:00 am', '3'],
      ['4:00 am', '4'],
      ['5:00 am', '5'],
      ['6:00 am', '6'],
      ['7:00 am', '7'],
      ['8:00 am', '8'],
      ['9:00 am', '9'],
      ['10:00 am', '10'],
      ['11:00 am', '11'],
      ['12:00 noon', '12'],
      ['1:00 pm', '13'],
      ['2:00 pm', '14'],
      ['3:00 pm', '15'],
      ['4:00 pm', '16'],
      ['5:00 pm', '17'],
      ['6:00 pm', '18'],
      ['7:00 pm', '19'],
      ['8:00 pm', '20'],
      ['9:00 pm', '21'],
      ['10:00 pm', '22'],
      ['11:00 pm', '23'],
      ['11:59 pm', '24']
    ]
  end

  def days_of_the_week
    ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
  end

  def friendly_schedules(schedules, new_lines=false)
    result = []
    by_wday = schedules.sort_by{|s| s.wday }.group_by {|s| s.wday}
    by_wday.each do |wday, schedules|
      all_ranges = schedules.map {|s| (s.start_time.to_i..s.end_time.to_i) }.uniq
      ranges = []
      all_ranges.each do |range|
        ranges << all_ranges.map {|r| combine_overlapping(range,r)}
      end
      ranges = remove_overlapping(ranges).sort_by{ |r| r.first }
      ranges_string = ranges.map {|r| range_to_s(r) }
      day = "<strong>#{days_of_the_week[wday-1]}s</strong>"
      if new_lines
        day += "<div style='margin-left:10px'>#{ranges_string.to_sentence}</div>"
      else
        day += " #{ranges_string.to_sentence}"
      end
      result << day
    end

    result.join("<br />").html_safe
  end

  def combine_overlapping(range1, range2)
    if range1 != range2 && range1.include?(range2.first)
      [(range1.first..range2.last)]
    else
      [range1, range2]
    end
  end
  private :combine_overlapping

  def remove_overlapping(ranges)
    ranges = ranges.flatten.uniq
    all    = ranges.dup
    all2   = ranges.dup
    ranges.each do |range|
      all2.map {|r| all.delete(r) if r != range && range.include?(r) }
    end
    all
  end
  private :remove_overlapping

  def range_to_s(range)
    "#{am_pm(range.first)} - #{am_pm(range.last)}"
  end
  private :range_to_s

  def am_pm(range)
    if range == 0
      "12am"
    elsif range <= 11
      "#{range}am"
    elsif range == 24
      "midnight"
    else
      "#{range == 12 ? range : range - 12}pm"
    end
  end
  private :am_pm
end
