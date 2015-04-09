class ForecastCrawler
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform()
    url = 'http://www.airkorea.or.kr/dustForecast'
    html = Net::HTTP.get(URI(url))
    html = html.force_encoding(Encoding::UTF_8)

    m = html.match('(\d{4}-\d{2}-\d{2} \d{2}) 시')
    date = m[1].to_time

    m = m.post_match.match('미세먼지 내일예보')

    today = get_forecast_data(m.pre_match)
    tomorrow = get_forecast_data(m.post_match)

    f = Forecast.find_or_initialize_by(date: date)
    f.today_grade = today[:grade]
    f.today_table = today[:table]
    f.today_analysis = today[:analysis]
    if tomorrow
      f.tomorrow_grade = tomorrow[:grade]
      f.tomorrow_table = tomorrow[:table]
      f.tomorrow_analysis = tomorrow[:analysis]
    end
    f.save
  end

  private
  def get_forecast_data(html)
    m = html.match('inform_overall"[^>]+>([^<]+)')
    return unless m
    
    grade = m[1]
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
    table = {}
    states.each_with_index do |state, i|
      table[state] = {
        dust: dust_array[i],
        pm10: pm10_array[i],
        pm25: pm25_array[i],
      }
    end

    m.post_match.match('cols="104">([^<]+)</textarea')
    analysis = m[1]

    {
      grade: grade,
      table: table,
      analysis: analysis,
    }
  end
end
