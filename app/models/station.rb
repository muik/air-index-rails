class Station
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  field :_id, type: String, default: ->{ code }
  field :code, type: String
  field :name, type: String
  field :no, type: Integer     # 지역내 순서
  field :address, type: String
  field :modified_address, type: String
  field :reserved_address, type: String
  field :coordinates, :type => Array
  belongs_to :region
  has_many :measures
  geocoded_by :address_for_geocode
  reverse_geocoded_by :coordinates, address: :reserved_address
  after_validation :geocode, :reverse_geocode

  index({ region_id: 1, no: 1 }, { background: true})

  def address_for_geocode
    modified_address or address_fixed
  end

  before_update do |document|
    document.geocode if document.modified_address_changed? or document.address_changed?
  end

  def address_fixed
    address.strip.gsub(/\([^\)]+\)/, ' ').gsub(',', '').strip.gsub(/옥상$/, '').strip
  end
end
