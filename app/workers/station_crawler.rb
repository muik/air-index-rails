class StationCrawler
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(districtnum, station_code, region_no)
    http = Net::HTTP
    url = 'http://www.airkorea.or.kr/stationInfo'
    uri = URI(url)
    res = http.post_form(uri, {
      action: 'station',
      loading: 'yes',
      leftShow: 'realTime',
      districtnum: districtnum,
      stationCode: station_code,
      areaImg: region_no
    })
    html = res.body
    html = html.force_encoding(Encoding::UTF_8)
    results = html.scan(/\)">([^<]+)<\/a><\/td>\s+\n.+vrmlSearch\('(\d+)', '(\d+)', '(\d+)'\)">([^<]+)/)

    for data in results
      region = Region.find_by(code: data[2])
      station = Station.find_or_initialize_by(code: data[1])
      station.name = data[0]
      station.no = data[3]
      station.address = data[4]
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
