json.array!(@stations) do |station|
  json.extract! station, :id, :code, :name, :region, :no, :address
  json.url station_url(station, format: :json)
end
