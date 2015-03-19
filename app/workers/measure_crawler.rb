class MeasureCrawler
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(station_code)
    station = Station.find station_code
    http = Net::HTTP
    url = "http://www.airkorea.or.kr/web/pollution/getRealChart?dateDiv=1&period=1&stationCode=#{station.code}"
    uri = URI(url)
    json = http.get(uri)
    obj = JSON.parse json
    charts = obj['charts']
    for data in charts
      Measure.new(station: station,
                  time: Time.strptime(data['DATA_TIME'], '%m-%d:%H'),
                  grade: data['KHAI_GRADE'],
                  index: data['KHAI_VALUE'],
                  major: data['KHAI_ITEM_CODE']).upsert
    end
  end
end
