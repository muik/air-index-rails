class Measure
  include Mongoid::Document
  include Mongoid::Timestamps
  field :time, type: Time
  field :grade, type: Integer   # 통합대기등급
  field :index, type: Integer   # 통합대기지수
  field :major, type: String    # 주오염물질
      # 10001: 아황산가스
      # 10002: 일산화탄소
      # 10003: 오존
      # 10006: 이산화질소
      # 10007: PM10
      # 10008: PM2.5
  belongs_to :station

  index({ station_id: 1, time: -1 }, { unique: true })
end
