json.array!(@regions) do |region|
  json.extract! region, :id, :code, :name, :no, :station_code
  json.url region_url(region, format: :json)
end
