class ApplicationRecord < ActiveRecord::Base
  include PgSearch::Model
  primary_abstract_class

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
  
  def country_code
    return "ES" if country.nil?
    return Country.named(country)&.alpha_2_code if country.count("a-zA-Z") > 2
    country
  end
end
