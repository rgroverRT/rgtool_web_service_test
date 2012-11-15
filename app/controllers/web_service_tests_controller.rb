class WebServiceTestsController < ApplicationController
require 'net/http'
    def new
        logger.debug("'new' method called in #{self.controller_name}")
        @web_service_test = WebServiceTest.new
        @web_service_test .name = "initial name"
        @web_service_test .test_method = "-- Select a method to test --"
        @web_service_test .mime_type = "-- Select a mime type --"

        @test_method_list = ["-- Select a method to test --", "GET", "PUT"]
        @mime_type_list = ["-- Select a mime type --", "XML", "JSON"]

        @test_response = session[:test_response] ||= {response_text: "will go here ..."}
    end

    def create
        logger.debug("'create' method called in #{self.controller_name}")
        @wst = WebServiceTest.new(params[:web_service_test])

        # HERE IT IS, the CALL!!
        #session[:test_response] = make_request
        session[:test_response] = {response_text: DateTime::now.to_s + ":  hard-coded response;  would send, recieve, and update this text ..."}

        # TODO:  get real status code
        @wst.status = 200

        if false #figure out if/when we want to write the result into the DB
            logger.debug("saving this WST:  " + @wst.to_s)
            @wst.save
        end

        redirect_to new_web_service_test_path()

    end

    private
        def make_request
            #url = URI.parse('http://localhost:3000/subscriptions/oldest.json')
            #req = Net::HTTP::Get.new(url.path)
            #res = Net::HTTP.start(url.host, url.port) {|http|
            #    http.request(req)
            #}
            ##response = JSON(res.body)["product"]
            #response = JSON.parse res.body
            #logger.debug("RESPONSE:  " + response.to_s)
            ##return response
            #return DateTime::now.to_s + "closer ... made the call ..."
        end

end
