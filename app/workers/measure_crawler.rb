class MeasureCrawler
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def self.perform_all
    Station.all.each {|s| MeasureCrawler.perform_async(s.code)}
  end

  def perform(station_code)
    station = Station.find_by(code: station_code)
    http = Net::HTTP
    url = "http://www.airkorea.or.kr/web/pollution/getRealChart?dateDiv=1&period=1&stationCode=#{station.code}"
    uri = URI(url)
    json = http.get(uri)
    obj = JSON.parse json
    charts = obj['charts']
    for data in charts
      m = Measure.find_or_initialize_by(
        station: station,
        time: Time.strptime(data['DATA_TIME'], '%m-%d:%H'))
      m.grade = data['KHAI_GRADE']
      m.index = data['KHAI_VALUE']
      m.major = data['KHAI_ITEM_CODE']
      m.save
    end
  end
end
