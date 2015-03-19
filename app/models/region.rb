class Region
  include Mongoid::Document
  include Mongoid::Timestamps
  field :_id, type: String, default: ->{ code }
  field :code, type: String # 국번
  field :name, type: String
  field :no, type: Integer  # 순서
  field :station_code, type: String
  has_many :stations
end
