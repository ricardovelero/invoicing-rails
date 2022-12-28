class Client < ApplicationRecord
  belongs_to :user
  has_many :invoices

  validates :first_name,
            :last_name,
            :nif,
            :street,
            :city,
            :region,
            :postal_code,
            :country,
            presence: true
    
  pg_search_scope :search, 
    against: [:first_name, :last_name, :nif, :city, :region, :country],
    using: { tsearch: { prefix: true } },
    ignoring: :accents

  def full_name
    [first_name, last_name].reject(&:blank?).collect(&:capitalize).join(" ")
  end

  def address
    [street, city, postal_code, region, country].reject(&:blank?).collect(&:titleize).join(", ")
  end

  def address_line_1
    [street].reject(&:blank?).collect(&:titleize).join(", ")
  end

  def address_line_2
    [city, postal_code, region, country].reject(&:blank?).collect(&:titleize).join(", ")
  end

  def country_code
    return "ES" if country.nil?
    return Country.named(country)&.alpha_2_code if country.count("a-zA-Z") > 2
    country
  end

  def get_regions
    @regions = Array.new
    if new_record?
      Country.alpha_2_coded("ES").subregions.each { |r| @regions << r.subregions }
    else
      if country.count("a-zA-Z") > 2
        Country.named(country)&.subregions&.each { |r| @regions << r.subregions }
        @regions = @regions.reject { |c| c.empty? }
        if @regions.empty?
          @regions = Array.new
          Country.named(country)&.subregions&.each { |r| @regions << r }
        end
      else
        Country.alpha_2_coded(country).subregions.each { |r| @regions << r.subregions }
        @regions = @regions.reject { |c| c.empty? }
        if @regions.empty?
          @regions = Array.new
          Country.alpha_2_coded(country).subregions.each { |r| @regions << r }
        end
      end
    end
    @regions.flatten.sort
  end
end
