class ForecastCrawler
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform()
    forecasts = AirKorea.client.forecasts

    today = forecasts[:today]
    tomorrow = forecasts[:tomorrow]

    f = Forecast.find_or_initialize_by(date: forecasts[:date])
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
end
