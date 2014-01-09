module SponsorsHelper
  def friendly_minutes_remaining(min)
    result = ''
    hours = min / 60
    remaining = min % 60

    result += hours.to_s if hours > 0

    if (15..60).include?(remaining)
      result += '&#189;'
    end
    result.html_safe
  end

  def sponsor_image(sponsor)
    if sponsors_images? && sponsor.image?
      image = sponsor.image.url(:actual).gsub('http:','')
    else
      image = '/images/sponsor-default.png'
    end
    image_tag(image, :width => 110, :height => 60, :class => 'sponsor-image')
  end
end
