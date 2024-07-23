require 'rails_helper'

RSpec.describe Api::V1::CompaniesController, type: :controller do
  before do
    allow_any_instance_of(YCombinatorScraper).to receive(:scrape).and_return(true)
  end

  let(:file_path) { Rails.root.join('public', 'companies_data.csv') }

  before do
    File.delete(file_path) if File.exist?(file_path)
  end

  after do
    File.delete(file_path) if File.exist?(file_path)
  end

  describe "GET #index" do
    context "when no limit is provided" do
      it "returns a default number of records" do
        CSV.open(file_path, 'w') do |csv|
          csv << ["Company Name", "Location", "Description", "Company Yc Batch", "Founders and LinkedIn URLs", "Website"]
          13.times do |i|
            csv << ["Company #{i}", "Location #{i}", "Description #{i}", "Batch #{i}", "Founder #{i}, LinkedIn URL #{i}", "Website #{i}"]
          end
        end

        get :index
        data = JSON.parse(response.body)
        default_limit = 10
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(data.length).to be <= default_limit
      end
    end

    context "when a limit is provided" do
      it "returns the correct number of records" do
        CSV.open(file_path, 'w') do |csv|
          csv << ["Company Name", "Location", "Description", "Company Yc Batch", "Founders and LinkedIn URLs", "Website"]
          16.times do |i|
            csv << ["Company #{i}", "Location #{i}", "Description #{i}", "Batch #{i}", "Founder #{i}, LinkedIn URL #{i}", "Website #{i}"]
          end
        end

        get :index, params: { limit: 5 }
        data = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(data.length).to eq(5)
      end
    end

    context "when the CSV file does not exist" do
      it "returns an empty array" do
        get :index
        data = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(data).to eq([])
      end
    end

    context "when scraper raises an error" do
      it "handles RuntimeError with a 404 status" do
        allow_any_instance_of(YCombinatorScraper).to receive(:scrape).and_raise(RuntimeError, "Scraper not found")
        get :index
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include("Scraper not found")
      end

      it "handles general errors with a 422 status" do
        allow_any_instance_of(YCombinatorScraper).to receive(:scrape).and_raise(StandardError, "General error")
        get :index
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("General error")
      end
    end

    it "passes the correct URL to the scraper" do
      base_url = 'https://www.ycombinator.com/companies'
      expected_url = 'https://www.ycombinator.com/companies?top_company=true&batch=S21&industry=B2B'
      limit = 10
      file_path = Rails.root.join('public', 'companies_data.csv')
      CSV.open(file_path, 'w') do |csv|
        csv << ["Company Name", "Location", "Description", "Company Yc Batch", "Founders and LinkedIn URLs", "Website"]
        csv << ["Company A", "Location A", "Description A", "Batch A", "Founder A, LinkedIn URL A", "Website A"]
      end
      scraper_double = double('YCombinatorScraper')
      allow(scraper_double).to receive(:scrape).and_return(true)
      expect(YCombinatorScraper).to receive(:new).with(expected_url, base_url, limit).and_return(scraper_double)
      get :index, params: { top_company: 'true', batch: 'S21', industry: 'B2B', limit: limit }
      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end
  end
end
