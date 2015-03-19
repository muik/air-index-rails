json.array!(@measures) do |measure|
  json.extract! measure, :id, :station, :time, :grade, :index
  json.url measure_url(measure, format: :json)
end
