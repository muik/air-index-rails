class RegionCrawler
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform()
    results = AirKorea.client.regions
    for data in results
      region = Region.find_or_initialize_by(code: data[:code])
      region.name = data[:name]
      region.no = data[:no]
      region.station_code = data[:station_code]
      region.save

      StationCrawler.perform_async region.code, region.station_code, region.no
    end
  end
end
