class Api::V1::CompaniesController < ApplicationController

  def index
    file_path = Rails.root.join('public', 'companies_data.csv')
    base_url = 'https://www.ycombinator.com/companies'
    limit = params[:limit].to_i if params[:limit]
    filters = {
      'batch' => params[:batch],
      'industry' => params[:industry],
      'regions' => params[:regions],
      'isHiring' => params[:isHiring],
      'tag' => params[:tag],
      'highlight_black' => params[:highlight_black],
      'highlight_women' => params[:highlight_women]
    }.compact
    if params[:team_size].present?
      min, max = params[:team_size].split('-')
      filters['team_size'] = "[\"#{min}\",\"#{max}\"]"
    end
    uri = URI(base_url)
    if filters.any?
      query_string = URI.encode_www_form(filters).gsub('+', '%20')
      uri.query = query_string
    end
    new_url_base = uri.to_s
    scraper = YCombinatorScraper.new(new_url_base, base_url, limit)
    scraper.scrape
    if File.exist?(file_path)
      @csv_data = CSV.read(file_path, headers: true)
    else
      @csv_data = []
    end
    render json: @csv_data
  end

end
