class WebServiceTestsController < ApplicationController
require 'net/http'
    DefaultServer = "http://localhost:3000"

    def new
        logger.debug("'new' method called in #{self.controller_name}")
        @web_service_test = WebServiceTest.new
        @web_service_test.name = "initial name"
        @web_service_test.test_method = "-- Select a method to test --"
        @web_service_test.mime_type = "-- Select a mime type --"
        @web_service_test.server = DefaultServer
        @web_service_test.resource = '/subscriptions/oldest'

        @test_method_list = ["-- Select a method to test --", "GET", "PUT"]
        @mime_type_list = ["-- Select a mime type --", "XML", "JSON"]

        @test_response = session[:test_response] ||= {response_text: "will go here ..."}
    end

    def create
        logger.debug("'create' method called in #{self.controller_name}")
        wst = WebServiceTest.new(params[:web_service_test])

        # HERE IT IS, the CALL!!
        test_response = make_request(wst)

        # Pass it across the redirect - TODO:  figure if there's another way
        session[:test_response] = test_response
        #{response_text: DateTime::now.seconds_since_midnight.to_s + ":  hard-coded response;  would send, recieve, and update this text ..."}

        wst.status = test_response.status

        if false #figure out if/when we want to write the result into the DB
            logger.debug("saving this WST:  " + wst.to_s)
            wst.save
        end

        redirect_to new_web_service_test_path()
    end

    private
        # TODO: try setting some header info for the request type instead of just hammering the file suffix to the mime type
        #
        def make_request(in_web_service_test)

            case in_web_service_test.mime_type
                when 'JSON'
                    suffix = '.json'
                when 'XML'
                    suffix = '.xml'
                else
                    raise ArgumentError, "select a supported mime type"
            end

            url = URI.parse(in_web_service_test.server + in_web_service_test.resource + suffix)

            case in_web_service_test.test_method
                when 'GET'
                    req = Net::HTTP::Get.new(url.path)
                when 'POST'
                    raise ArgumentError, "POST not supported"
                else
                    raise ArgumentError, "select a supported method to test"
            end

            # DA CALL!!
            res = Net::HTTP.start(url.host, url.port) { |http|
                http.request(req)
            }

            raw_response = res.body

            #response = JSON(res.body)["product"]
            #json_parsed_response = JSON.parse res.body
            #logger.debug("JSON RESPONSE:  " + json_parsed_response.to_s)

            # alloc and init a test_response resource
            test_response = TestResponse.new
            test_response.status = res.code
            test_response.response_text = DateTime::now.seconds_since_midnight.to_s + ":  " + raw_response.to_s #for now;  TODO clean this up, parse, extract, etc.

            return test_response
            #return DateTime::now.to_s + "closer ... made the call ..."
        end

end
