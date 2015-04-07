json.array!(@forecasts) do |forecast|
  json.extract! forecast, :id, :date, :today_grade, :today_table, :today_analysis
  json.url forecast_url(forecast, format: :json)
end
