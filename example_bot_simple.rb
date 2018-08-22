#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

USER_AGENTS = ['Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)',
              'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
              'Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.4b) Gecko/20030516 Mozilla Firebird/0.6',
              'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; de-at) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10',
              'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6',
              'Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.4a) Gecko/20030401',
              'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624',
              'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.1) Gecko/20100122 firefox/3.6.1',
              'Mozilla/5.0 (compatible; Konqueror/3; Linux)',
              'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.71 Safari/537.36',
              'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.62 Safari/537.36',
              'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.172 Safari/537.22',
              'Mozilla/5.0 (MSIE 8.0; Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko',
              'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; WOW64; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center',
              'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.71 Safari/537.36',
              'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) ; .NET CLR 3.5.30729)']

def random_agent
  USER_AGENTS[rand(USER_AGENTS.size-1)]
end

Capybara.run_server = false
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {
    # Raise JavaScript errors to Ruby
    js_errors: false,
    window_size: [1920, 1080],
    timeout: 10000,
    # Additional command line options for PhantomJS
    phantomjs_options: [
      '--load-images=no', 
      '--disk-cache=false', 
      '--ignore-ssl-errors=yes',
      '--ssl-protocol=any',
      '--proxy=localhost:8118'
    ]
  })
end
Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
# Capybara.default_wait_time = 10 

class Devourer
  include Capybara::DSL

  def ddg_search(my_question)
    retry_attempts = 0
    begin
      page.driver.headers = {"User-Agent" => random_agent}
      puts 'Going to DuckDuckGo...'
      visit 'https://duckduckgo.com'
    rescue => e
      puts e
      retry_attempts += 1
      raise 'Failed to reach DDG after 3 attempts.' if retry_attempts > 3
      sleep (retry_attempts * 15) 
      retry
    end

    puts "We got #{page.current_url}"

    fill_in('q', with: my_question)
    click_button 'search_button_homepage'

    page.all(:xpath, '//*[@class="result__body links_main links_deep"]').each do |result|
      puts result.find(:xpath, './h2/a[1]').text
      puts "    #{result.find(:xpath, './h2/a[1]')['href']}"
    end
  end 

end

###########################
# Start of actual program #
###########################
devourer = Devourer.new

my_question = ARGV[0] || 'Recursion'

devourer.ddg_search my_question
