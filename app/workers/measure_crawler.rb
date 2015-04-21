class MeasureCrawler
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def self.perform_all
    Station.all.each {|s| MeasureCrawler.perform_async(s.code)}
  end

  def perform(station_code)
    station = Station.find_by(code: station_code)
    measures = AirKorea.client.measures(station_code)

    for data in measures
      m = Measure.find_or_initialize_by(
        station: station,
        time: data[:time])
      m.grade = data[:grade]
      m.index = data[:index]
      m.major = data[:major]
      m.save
    end
  end
end
