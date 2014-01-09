module AccountsHelper
  def pretty_hotline_number(number)
    number_to_phone(number.gsub('+1',''), :area_code => true)
  end
end
