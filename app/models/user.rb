class User
  include Mongoid::Document
  belongs_to :station
end
