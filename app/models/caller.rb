class Caller < ActiveRecord::Base
  belongs_to :account
  has_many :calls

  def over_caller?
    false
  end
end
