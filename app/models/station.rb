class Station
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  field :code, type: String
  field :name, type: String
  field :no, type: Integer     # 지역내 순서
  field :address, type: String
  field :modified_address, type: String
  field :reserved_address, type: String
  field :coordinates, :type => Array
  field :province, type: String # 예보 구분 지역
  belongs_to :region
  has_many :measures
  has_many :users
  geocoded_by :address_for_geocode
  reverse_geocoded_by :coordinates, address: :reserved_address
  after_validation :geocode, :reverse_geocode

  index({ region_id: 1, no: 1 }, { background: true })
  index({ coordinates: '2d' }, { min: -200, max: 200, background: true })
  index({ code: 1 }, { unique: true })

  def address_for_geocode
    modified_address or address_fixed
  end

  before_save do |document|
    document.geocode if document.modified_address_changed? or document.address_changed?
    document.set_province if document.address_changed?
  end

  def address_fixed
    address.strip.gsub(/\([^\)]+\)/, ' ').
      gsub(',', '').
      strip.gsub(/옥상$/, '').
      strip.gsub(/(\d)(번지.+)$/, '\1').
      strip.gsub(/(\d+-\d+)[^\d].+$/, '\1').
      strip
  end

  def get_last_measure
    Measure.where(station_id: id).order_by(time: -1).first
  end

  def set_province
    self.province = get_province
  end

  private
  def get_province
    city = address.split(' ')[1]

    if region.name == '경기'
      south_city_set = Set.new %w(수원시 성남시 안양시 부천시 안산시 용인시 광명시 평택시 과천시 오산시 시흥시 군포시 의왕시 하남시 이천시 안성시 김포시 화성시 광주시 여주시 양평군)
      north_city_set = Set.new %w(고양시 의정부시 동두천시 구리시 남양주시 파주시 양주시 포천시 연천군 가평군)

      if south_city_set.include? city
        return '경기남부'
      elsif north_city_set.include? city
        return '경기북부'
      end
    elsif region.name == '강원'
      east_cities = Set.new %w(고성군 속초시 양양군 강릉시 동해시 삼척시 태백시)
      west_cities = Set.new %w(춘천시 원주시 홍천시 양구군 횡성군 정선군)

      if east_cities.include? city
        return '영동'
      elsif west_cities.include? city
        return '영서'
      end
    else
      return region.name
    end

    logger.warn "지역군 구별불가 도시: #{city}"
    return nil
  end
end
