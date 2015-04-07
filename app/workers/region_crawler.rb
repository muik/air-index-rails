class RegionCrawler
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform()
    url = 'http://www.airkorea.or.kr/stationInfo'
    html = Net::HTTP.get(URI(url))
    html = html.force_encoding(Encoding::UTF_8)
    results = html.scan(/<area class="sub_gis_map_\d+" alt="([^"]+)"\s+href="javascript:searchInfo\('(\d+)',\s?'(\d+)','(\d+)/)
    for data in results
      region = Region.find_or_initialize_by(code: data[1])
      region.name = data[0]
      region.no = data[3]
      region.station_code = data[2]
      region.save

      StationCrawler.perform_async region.code, region.station_code, region.no
    end
  end
end
