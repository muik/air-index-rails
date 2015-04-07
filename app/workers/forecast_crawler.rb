class ForecastCrawler
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform()
    data = get_forecast_data
    f = Forecast.find_or_initialize_by(date: data[:date])
    f.today_grade = data[:today_grade]
    f.today_table = data[:today_table]
    f.today_analysis = data[:today_analysis]
    f.save

    logger.info results
  end

  private
  def get_forecast_data
    url = 'http://www.airkorea.or.kr/dustForecast'
    html = Net::HTTP.get(URI(url))
    html = html.force_encoding(Encoding::UTF_8)
    m = html.match('(\d{4}-\d{2}-\d{2} \d{2}) 시')
    date = m[1].to_time
    m = m.post_match.match('inform_overall"[^>]+>([^<]+)')
    today_grade = m[1]
    m = m.post_match.match('미세먼지</th>\s+')
    m = m.post_match.match('</tr>')
    results = m.pre_match.scan(/">([^<]+)</)
    dust_array = results.flatten
    m = m.post_match.match('PM<sub>10</sub>')
    m = m.post_match.match('</tr>')
    results = m.pre_match.scan(/>([^<]+)<\//)
    pm10_array = results.flatten
    m = m.post_match.match('PM<sub>2.5</sub>')
    m = m.post_match.match('</tr>')
    results = m.pre_match.scan(/>([^<]+)<\//)
    pm25_array = results.flatten

    states = %w(서울  인천  경기북부  경기남부  영서  영동 충청권  호남권  영남권  제주권)
    today_table = {}
    states.each_with_index do |state, i|
      today_table[state] = {
        dust: dust_array[i],
        pm10: pm10_array[i],
        pm25: pm25_array[i],
      }
    end

    m.post_match.match('cols="104">([^<]+)</textarea')
    today_analysis = m[1]

    {
      date: date,
      today_grade: today_grade,
      today_table: today_table,
      today_analysis: today_analysis,
    }
  end
end
