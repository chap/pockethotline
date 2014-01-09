class OutgoingCall < ActiveRecord::Base
  belongs_to :account
  belongs_to :call
  belongs_to :operator, :class_name => 'User'
end
