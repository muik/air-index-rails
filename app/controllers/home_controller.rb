class HomeController < ApplicationController
  def index
    unless cookies[:uuid]
      cookies[:uuid] = SecureRandom.uuid
    end

    @user = User.find_or_create_by(id: cookies[:uuid])

    if request.xhr?
      lat = params[:lat].to_f
      lng = params[:lng].to_f
      s = Station.geo_near([lng, lat]).first
      #unless @user.station_id == s.id
      unless @user.station_id
        @user.station_id = s.id
        @user.save
      end
      m = s.get_last_measure
      render json: get_response(s, m)
    else
      if @user.station_id
        @station = @user.station 
        @measure = @station.get_last_measure
        @data = get_response(@station, @measure)
      end
    end
  end

  private
  def get_response(s, m)
    measure_day = get_day_text(m.time)
    f = Forecast.order_by(date: -1).first
    forecast_day = get_day_text(f.date)

    {
      station: {
        name: s.name,
        id: s.id.to_s,
      },
      measure: {
        grade: m.grade,
        time: m.time.localtime.strftime("#{measure_day} %-H시"),
      },
      forecasts: {
        time: f.date.localtime.strftime("#{forecast_day} %-H시"),
        today: {
          grade: f.today_grade
        },
        tomorrow: {
          grade: f.tomorrow_grade || '17시에 발표'
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
