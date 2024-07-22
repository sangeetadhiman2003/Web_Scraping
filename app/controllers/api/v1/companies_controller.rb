class Api::V1::CompaniesController < ApplicationController

  def index
    file_path = Rails.root.join('public', 'companies_data.csv')
    new_url_base = 'https://www.ycombinator.com/companies'
    scraper = YCombinatorScraper.new('https://www.ycombinator.com/companies', new_url_base)
    scraper.scrape
    if File.exist?(file_path)
      @csv_data = CSV.read(file_path, headers: true)
    else
      @csv_data = []
    end
  end

end
