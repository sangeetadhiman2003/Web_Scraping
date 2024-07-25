require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Api::V1::CompaniesController, type: :controller do
  before do
    @base_url = 'https://www.ycombinator.com/companies'
    stub_request(:get, @base_url)
      .to_return(status: 200, body: "<html><body>Test Content</body></html>", headers: {})
  end

  describe 'GET #index' do
    context 'with top_company parameter' do
      before do
        @params = { top_company: 'true', limit: 10 }
        @expected_url = "#{@base_url}?top_company=#{@params[:top_company]}"
        scrape_service = instance_double(YCombinatorScraper)
        allow(YCombinatorScraper).to receive(:new).with(@expected_url, @base_url, @params[:limit]).and_return(scrape_service)
        allow(scrape_service).to receive(:scrape).and_return([])
      end

      it 'returns a successful response' do
        get :index, params: @params
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with highlight_women parameter' do
      before do
        @params = { highlight_women: 'true', limit: 10 }
        @expected_url = "#{@base_url}?highlight_women=#{@params[:highlight_women]}"
        scrape_service = instance_double(YCombinatorScraper)
        allow(YCombinatorScraper).to receive(:new).with(@expected_url, @base_url, @params[:limit]).and_return(scrape_service)
        allow(scrape_service).to receive(:scrape).and_return([])
      end

      it 'returns a successful response' do
        get :index, params: @params
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with highlight_black parameter' do
      before do
        @params = { highlight_black: 'true', limit: 10 }
        @expected_url = "#{@base_url}?highlight_black=#{@params[:highlight_black]}"

        scrape_service = instance_double(YCombinatorScraper)
        allow(YCombinatorScraper).to receive(:new).with(@expected_url, @base_url, @params[:limit]).and_return(scrape_service)
        allow(scrape_service).to receive(:scrape).and_return([])
      end

      it 'returns a successful response' do
        get :index, params: @params

        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with batch parameter' do
      before do
        @params = { batch: 'W09', limit: 10 }
        @expected_url = "#{@base_url}?batch=#{@params[:batch]}"

        scrape_service = instance_double(YCombinatorScraper)
        allow(YCombinatorScraper).to receive(:new).with(@expected_url, @base_url, @params[:limit]).and_return(scrape_service)
        allow(scrape_service).to receive(:scrape).and_return([])
      end

      it 'returns a successful response' do
        get :index, params: @params
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with industry parameter' do
      before do
        @params = { industry: 'B2B', limit: 10 }
        @expected_url = "#{@base_url}?industry=#{@params[:industry]}"
        scrape_service = instance_double(YCombinatorScraper)
        allow(YCombinatorScraper).to receive(:new).with(@expected_url, @base_url, @params[:limit]).and_return(scrape_service)
        allow(scrape_service).to receive(:scrape).and_return([])
      end

      it 'returns a successful response' do
        get :index, params: @params
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with tag parameter' do
      before do
        @params = { tag: 'saas', limit: 10 }
        @expected_url = "#{@base_url}?tag=#{@params[:tag]}"
        scrape_service = instance_double(YCombinatorScraper)
        allow(YCombinatorScraper).to receive(:new).with(@expected_url, @base_url, @params[:limit]).and_return(scrape_service)
        allow(scrape_service).to receive(:scrape).and_return([])
      end

      it 'returns a successful response' do
        get :index, params: @params
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with regions parameter' do
      before do
        @params = { regions: 'CA', limit: 10 }
        @expected_url = "#{@base_url}?regions=#{@params[:regions]}"
        scrape_service = instance_double(YCombinatorScraper)
        allow(YCombinatorScraper).to receive(:new).with(@expected_url, @base_url, @params[:limit]).and_return(scrape_service)
        allow(scrape_service).to receive(:scrape).and_return([])
      end

      it 'returns a successful response' do
        get :index, params: @params
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with top_company and batch parameters' do
      before do
        @params = { top_company: 'true', batch: 'S21', industry: 'B2B', limit: 10 }
        @expected_url = "#{@base_url}?top_company=#{@params[:top_company]}&batch=#{@params[:batch]}&industry=#{@params[:industry]}"
        scrape_service = instance_double(YCombinatorScraper)
        allow(YCombinatorScraper).to receive(:new).with(@expected_url, @base_url, @params[:limit]).and_return(scrape_service)
        allow(scrape_service).to receive(:scrape).and_return([])
      end

      it 'returns a successful response' do
        get :index, params: @params
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with different parameters' do
      before do
        @params = { top_company: 'false', batch: 'W20', industry: 'Fintech', limit: 5 }
        @expected_url = "#{@base_url}?top_company=#{@params[:top_company]}&batch=#{@params[:batch]}&industry=#{@params[:industry]}"
        scrape_service = instance_double(YCombinatorScraper)
        allow(YCombinatorScraper).to receive(:new).with(@expected_url, @base_url, @params[:limit]).and_return(scrape_service)
        allow(scrape_service).to receive(:scrape).and_return([])
      end

      it 'returns a successful response' do
        get :index, params: @params
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with tag and regions parameters' do
      before do
        @params = { tag: 'saas', regions: 'CA', limit: 10 }
        @expected_url = "#{@base_url}?tag=#{@params[:tag]}&regions=#{@params[:regions]}"
        scrape_service = instance_double(YCombinatorScraper)
        allow(YCombinatorScraper).to receive(:new).with(@expected_url, @base_url, @params[:limit]).and_return(scrape_service)
        allow(scrape_service).to receive(:scrape).and_return([])
      end

      it 'returns a successful response' do
        get :index, params: @params
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end
end
