class Subdomain
  def self.matches?(request)
    request.subdomain.present? && !%w(www secure).include?(request.subdomain)
  end
end