# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ -> 
  return false if $('body.home.index').size() < 1

  gradeTexts = ['좋음', '보통', '나쁨', '매우나쁨', '데이터없음'];

  getLocation = () ->
    return false if !navigator.geolocation
    navigator.geolocation.getCurrentPosition(showPosition)
    true

  showPosition = (position) ->
    lat = position.coords.latitude
    lng = position.coords.longitude
    $.ajax('/?lat=' + lat + '&lng=' + lng).done(showMeasure)

  getGradeText = (gradeCode) ->
    if gradeCode < 1 || gradeCode > gradeTexts.length
      return '알수없음'
    gradeTexts[gradeCode - 1]

  showMeasure = (response, force) ->
    if force != true && window.response && window.response['station']['id'] != response['station']['id']
      return showNearStationConfirm(response)

    showPage('#content_page')

    grade = response['measure']['grade']
    forecasts = response['forecasts']
    $('body').attr('grade', grade)
    $('#grade').html(getGradeText(grade))
    $('#time').html(response['measure']['time'])
    $('#forecast_time').html('('+forecasts['time']+' 발표)')
    $('#station').html(response['station']['name'])
    $('#today_grade').html(forecasts['today']['grade'])
    $('#tomorrow_grade').html(forecasts['tomorrow']['grade'].replace(/\n/, '<br />'))

    dayForecasts = $('#day_forecasts')
    $('#province', dayForecasts).html(response['station']['province'])
    gradeText = forecasts['today']['province_grade'].dust
    gradeIndex = gradeTexts.indexOf(gradeText) + 1
    dayForecast = $('.day.today', dayForecasts)
    dayForecast.attr('grade', gradeIndex)
    $('.grade', dayForecast).html(gradeText)

    if forecasts['tomorrow']['province_grade']
      gradeText = forecasts['tomorrow']['province_grade'].dust
      gradeIndex = gradeTexts.indexOf(gradeText) + 1
    else
      gradeText = '(17시에 발표)'
      gradeIndex = ''
    dayForecast = $('.day.tomorrow', dayForecasts)
    dayForecast.attr('grade', gradeIndex)
    $('.grade', dayForecast).html(gradeText)

    window.response = response

  showNearStationConfirm = (response) ->
    $('#near_station_name').html(response['station']['name'])
    nearStationConfirm = $('#near_station_confirm')
    nearStationConfirm.slideDown()
    $('.close-text', nearStationConfirm).click(() ->
      $('#near_station_confirm').fadeOut()
      return false
    )
    nearStationConfirm.click(() ->
      showMeasure(response, true)
      $('#near_station_confirm').slideUp()
      $.cookie('station_id', response['station']['id'], { expires: 10 })
      return false;
    )

  showPage = (page_id) ->
    $('div.page').hide()
    $(page_id).show()

  $('#location_allow_page > button').click () ->
    showPage('#loading_page')
    unless getLocation()
      showPage('#location_allow_page')


  showPage('#loading_page')
  if response != null
    showMeasure(response)

  unless getLocation()
    showPage('#location_allow_page')

