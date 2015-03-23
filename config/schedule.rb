every 1.day, :at => '12:30 pm' do
  runner 'RegionCrawler::perform_async'
end

every 1.hours do
  runner 'MeasureCrawler::perform_all'
end
