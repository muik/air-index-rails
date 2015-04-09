class User
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :station
end
