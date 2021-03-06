if @environment != 'staging'
  every 1.day, :at => '12:30 pm' do
    runner 'RegionCrawler::perform_async'
  end

  every '0,10 * * * *' do
    runner 'MeasureCrawler::perform_all'
  end

  every '0,5 * * * *' do
    runner 'ForecastCrawler::perform_async'
  end
end
