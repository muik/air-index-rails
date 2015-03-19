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
      region = Region.find data[2]
      station = Station.new(code: data[1], name: data[0],
                  no: data[3].to_i, address: data[4],
                  region: region)
      station.upsert
      MeasureCrawler.perform_async station.code
    end
  end
end
