class Forecast
  include Mongoid::Document
  include Mongoid::Timestamps
  field :date, type: Time
  field :today_grade, type: String
  field :today_table, type: Hash
  field :today_analysis, type: String
  field :tomorrow_grade, type: String
  field :tomorrow_table, type: Hash
  field :tomorrow_analysis, type: String

  index({ date: -1 }, { unique: true, background: true })

  def today_grade_of(province)
    today_table[province]
  end

  def tomorrow_grade_of(province)
    tomorrow_table && tomorrow_table[province] || nil
  end
end
