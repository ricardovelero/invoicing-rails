class CountriesController < ApplicationController

  def regions
    @target = params[:target]
    @regions = Array.new
    Country.alpha_2_coded(params[:country]).subregions.each { |r| @regions << r.subregions }
    @regions = @regions.reject { |c| c.empty? }
    if @regions.empty?
      @regions = Array.new
      Country.alpha_2_coded(params[:country]).subregions.each { |r| @regions << r }
    end
    @regions = @regions.flatten.sort
    respond_to do |format|
      format.turbo_stream
    end
  end 
end
