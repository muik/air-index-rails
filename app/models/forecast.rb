class Forecast
  include Mongoid::Document
  include Mongoid::Timestamps
  field :date, type: String
  field :today_grade, type: String
  field :today_table, type: String
  field :today_analysis, type: String

  index({ date: -1 }, { unique: true, background: true })
end
