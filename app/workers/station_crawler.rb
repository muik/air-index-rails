class StationCrawler
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(region_code, station_code, region_no)
    region = Region.find_by(code: region_code)
    results = AirKorea.client.stations(region_code, station_code, region_no)

    for data in results
      station = Station.find_or_initialize_by(code: data[:code])
      station.name = data[:name]
      station.no = data[:no]
      station.address = data[:address]
      station.region = region
      station.set_province unless station.province
      station.save

      unless station.geocoded?
        station.geocode 
        station.save
      end

      MeasureCrawler.perform_async station.code
    end
  end
end
