require 'bundler/setup'
require 'capybara'
require 'pry'
require 'io/console'
require 'active_support/all'

DOWNLOAD_DIR = File.expand_path('../statements', __FILE__)
FileUtils.mkdir_p DOWNLOAD_DIR

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome,
    prefs: { # see https://code.google.com/p/selenium/wiki/RubyBindings
      download: {
        prompt_for_download: false,
        default_directory: DOWNLOAD_DIR
      }
    }
  )
end

class FirstDirectSession
  include Capybara::DSL

  def initialize(username="mark_evans")
    @username = username
    Capybara.default_driver = :selenium
  end

  attr_accessor :username

  def login
    # First page
    visit 'https://www1.firstdirect.com/1/2/idv.Logoff?nextPage=fsdtBalances'
    fill_in 'userid', with: username
    click_on 'Proceed'

    # Secure key page
    click_on "Log on without your Secure Key"

    # Password page
    labels = page.all('form label', visible: false)
    labels.each do |label|
      puts label.text(:all)
      value = STDIN.noecho(&:gets).chomp
      input = page.find("form ##{label['for']}")
      input.set(value)
    end
    click_on 'Proceed'
  end

  def back_to_top
    within('#fdLeftMenu') do
      click_on 'view statements'
    end
  end

  def ensure_logged_in
    unless @logged_in
      login
      @logged_in = true
    end
  end

  def download_statement(from: 90.days.ago, to: Date.yesterday)
    ensure_logged_in
    back_to_top
    click_on 'download'
    fill_in 'DownloadFromDate', with: from.strftime('%d/%m/%Y')
    fill_in 'DownloadToDate', with: to.strftime('%d/%m/%Y')
    select 'Microsoft Excel', from: 'DownloadFormat'
    download_file
  end

  def download_past_statement(month, year)
    ensure_logged_in
    back_to_top
    view_past_link = page.all('a').find{|a| a.text == 'view past months' } # click_on was erroring for some reason
    view_past_link.click
    statement_date = '25/%02d/%d' % [month, year]
    select statement_date, from: 'StatementDate'
    page.all('form a').select{|a| a.text == 'go' }.last.click
    click_on 'download'
    select 'Microsoft Excel', from: 'DownloadFormat'
    download_file
  end

  def download_file
    download_link = page.find('form a[name=download]')
    Statements.wait_for_downloaded_statement do
      # clicking errors for some reason
      download_link.native.send_keys(:enter)
    end
  end
end

#----------------------------------------------------------------------------
#
module Statements
  class << self
    def wait_for_downloaded_statement(&block)
      statements_before = statements
      yield
      begin
        sleep 0.1
        added_statements = statements - statements_before
      end until added_statements.any?
      Pathname.new(added_statements.first)
    end

    def statements
      Dir["#{DOWNLOAD_DIR}/*.{csv,CSV}"]
    end

    def each_month(&block)
      this_month_start = Date.today.beginning_of_month
      2011.upto(this_month_start.year) do |year|
        (1..12).each do |month|
          month_start = Date.new(year, month, 1)
          if month_start < this_month_start
            filename = filename(month_start)
            exists = File.exists?("#{DOWNLOAD_DIR}/#{filename}")
            yield month_start, filename, exists
          else
            break
          end
        end
      end
    end

    def filename(month_start)
      month_start.strftime('%Y-%m.csv')
    end
  end
end

#----------------------------------------------------------------------------

session = FirstDirectSession.new
Statements.each_month do |month_start, filename, exists|
  unless exists
    puts "Downloading statement #{filename}"
    session.download_past_statement(month_start.month, month_start.year).rename("#{DOWNLOAD_DIR}/#{filename}")
  end
end
puts "Downloading latest statement"
session.download_statement.rename("#{DOWNLOAD_DIR}/latest_statement.csv")
puts "done"
