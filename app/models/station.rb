class Station
  include Mongoid::Document
  include Mongoid::Timestamps
  field :_id, type: String, default: ->{ code }
  field :code, type: String
  field :name, type: String
  field :no, type: String   # 지역내 순서
  field :address, type: String
  belongs_to :region
end
