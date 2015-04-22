class HomeController < ApplicationController
  def index
    station_id = cookies[:station_id]

    if request.xhr?
      lat = params[:lat].to_f
      lng = params[:lng].to_f
      station = Station.geo_near([lng, lat]).first
      unless station_id
        station_id = station.id.to_s
        cookies[:station_id] = station_id
      end
      measure = station.last_measure
      render json: get_response(station, measure)
    else
      if station_id
        station = Station.find station_id
        measure = station.last_measure
        @data = get_response(station, measure)
      end
    end
  end

  private
  def get_response(station, measure)
    measure_day = get_day_text(measure.time)
    f = Forecast.recent.first
    forecast_day = get_day_text(f.date)

    {
      station: {
        name: station.name,
        id: station.id.to_s,
        province: station.province,
      },
      measure: {
        grade: measure.grade,
        time: measure.time.localtime.strftime("#{measure_day} %-H시"),
      },
      forecasts: {
        time: f.date.localtime.strftime("#{forecast_day} %H시"),
        today: {
          grade: f.today_grade,
          province_grade: f.today_grade_of(station.province),
        },
        tomorrow: {
          grade: f.tomorrow_grade || '17시에 발표',
          province_grade: f.tomorrow_grade_of(station.province),
        }
      }
    }
  end

  def get_day_text(time)
    past_days = (Time.now.localtime.strftime('%Y%m%d').to_time -
                 time.localtime.strftime('%Y%m%d').to_time) / 1.day
    if past_days == 0
      day = '오늘'
    elsif past_days == 1
      day = '어제'
    else
      day = "#{past_days}일 전"
    end
    day
  end
end
