class RegionCrawler
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform()
    http = Net::HTTP
    url = 'http://www.airkorea.or.kr/stationInfo'
    uri = URI(url)
    html = http.get(uri)
    html = html.force_encoding(Encoding::UTF_8)
    results = html.scan(/<area class="sub_gis_map_\d+" alt="([^"]+)"\s+href="javascript:searchInfo\('(\d+)',\s?'(\d+)','(\d+)/)
    logger.info results
    for data in results
      region = Region.new(code: data[1], name: data[0],
                 no: data[3], station_code: data[2])
      region.upsert
      StationCrawler.perform_async region.code, region.station_code, region.no
    end
  end
end
