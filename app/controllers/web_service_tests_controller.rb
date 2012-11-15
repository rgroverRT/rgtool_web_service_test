class WebServiceTestsController < ApplicationController
    def new
        logger.debug("'new' method called in #{self.controller_name}")
        @web_service_test = WebServiceTest.new
        @web_service_test.name = "initial name"
        @web_service_test.test_method = "-- Select a method to test --"
        @web_service_test.mime_type = "-- Select a mime type --"

        @test_method_list = ["-- Select a method to test --", "GET", "PUT"]
        @mime_type_list = ["-- Select a mime type --", "XML", "JSON"]
    end
end
