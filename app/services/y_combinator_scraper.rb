require 'csv'
require 'nokogiri'
require 'selenium-webdriver'

class YCombinatorScraper
  def initialize(url, new_url_base, limit = nil)
    @url = url
    @new_url_base = new_url_base
    @limit = limit

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')

    @driver = Selenium::WebDriver.for :chrome, options: options
  end

  def wait_for_page_load(timeout = 60)
    Selenium::WebDriver::Wait.new(timeout: timeout).until do
      @driver.execute_script('return document.readyState') == 'complete'
    end
  end

  def wait_for_specific_element(selector, timeout = 60)
    Selenium::WebDriver::Wait.new(timeout: timeout).until do
      @driver.find_element(css: selector).displayed?
    end
  end

  def wait_for_content_to_load(timeout = 60)
    Selenium::WebDriver::Wait.new(timeout: timeout).until do
      loading_elements = @driver.find_elements(css: 'div._status_86jzd_510')
      loading_elements.empty?
    end
  end

  def fetch_additional_data(company_name)
    formatted_name = company_name.downcase.gsub(' ', '-')
    new_url = "#{@new_url_base}/#{formatted_name}"
    begin
      @driver.navigate.to(new_url)
      wait_for_page_load
      page_source = @driver.page_source
      doc = Nokogiri::HTML(page_source)
      website_url = doc.at_css('div.group a')&.[](:href) || "N/A"
      founders = doc.css('section.relative.isolate.z-0 div.flex.flex-row.flex-col.items-start.gap-3.md\\:flex-row').map do |founder_div|
        founder_name = founder_div.at_css('div.leading-snug div.font-bold')&.text&.strip
        founder_linkedin = founder_div.at_css('div.leading-snug a.bg-image-linkedin')&.[](:href)
        "#{founder_name}: #{founder_linkedin}" if founder_name && founder_linkedin
      end.compact.join(", ") || "N/A"
      puts "URL: #{new_url}, Website URL: #{website_url}, Founders: #{founders}"
      @driver.navigate.to(@url)
      wait_for_page_load
      wait_for_specific_element('div._section_86jzd_146._results_86jzd_326')
      [founders, website_url]
    rescue Selenium::WebDriver::Error::NoSuchElementError
      ["Data not found", "N/A", "N/A"]
    rescue Selenium::WebDriver::Error::NoSuchWindowError
      ["Window not found", "N/A", "N/A"]
    rescue => e
      puts "Error fetching additional data: #{e.message}"
      ["Error", "N/A", "N/A"]
    end
  end

  def parse_page
    page_source = @driver.page_source
    doc = Nokogiri::HTML(page_source)
    company_listings = doc.css('div._section_86jzd_146._results_86jzd_326')
    file_path = 'public/companies_data.csv'
    CSV.open(file_path, "w") do |csv|
      csv << ["Company Name", "Location", "Description", "Company Yc Batch", "Founders and LinkedIn URLs", "Website URL"]
      processed_companies = 0
      company_listings.each do |listing|
        break if @limit && processed_companies >= @limit
        listing.css('a').each do |company_link|
          break if @limit && processed_companies >= @limit
          company_name = company_link.at_css('span._coName_86jzd_453')&.text.to_s.strip
          next if company_name.empty?
          company_location = company_link.at_css('span._coLocation_86jzd_469')&.text.to_s.strip
          company_description = company_link.at_css('span._coDescription_86jzd_478')&.text.to_s.strip
          company_yc_batch = company_link.at_css('div._pillWrapper_86jzd_33').at_css('a')&.at_css('span.pill')&.text&.strip
          founders, website_url = fetch_additional_data(company_name)
          next if [company_name, company_location, company_description, founders, website_url].all?(&:empty?)
          csv << [company_name, company_location, company_description, company_yc_batch, founders, website_url]
          processed_companies += 1
        end
      end
    end
  end

  def scrape
    begin
      @driver.navigate.to(@url)
      wait_for_page_load
      wait_for_specific_element('div._section_86jzd_146._results_86jzd_326')
      wait_for_content_to_load
      parse_page
    rescue Selenium::WebDriver::Error::TimeoutError => e
      puts "Navigation timed out: #{e.message}"
    rescue Selenium::WebDriver::Error::WebDriverError => e
      puts "WebDriver error: #{e.message}"
    ensure
      @driver.quit if @driver
    end
  end
end
