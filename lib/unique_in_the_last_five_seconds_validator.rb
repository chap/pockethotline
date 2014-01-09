class UniqueInTheLastFiveSecondsValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    if record.class.where("#{attribute} = ?", value).where('created_at >= ?', 5.seconds.ago).any?
      record.errors[attribute] << (options[:message] || "appears to be a duplicate")
    end
  end
end