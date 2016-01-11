require "../test_helper"
require "selenium-webdriver/selenium"

module Selenium
  class PageObject
    def load
      session.url = "http://localhost:9393/"
    end

    def uri
      URI.parse(session.url)
    end

    def session
      self.class.session
    end

    def self.load
      new.tap { |page| page.load }
    end

    def self.session
      @@session ||= driver.create_session({
        "browserName" => ENV.fetch("BROWSER_NAME", "firefox"),
        "platform" => "ANY",
      }, {} of String => String)
    end

    def self.driver
      @@driver ||= Selenium::Webdriver.new
    end
  end
end

#Minitest.after_run { Selenium::PageObject.session.stop }

require "./pages/*"
