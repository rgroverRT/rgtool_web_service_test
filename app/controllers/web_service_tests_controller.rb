require 'net/http'

class WebServiceTestsController < ApplicationController

    DEFAULT_SERVER = "http://localhost:3000"
    DEFAULT_RESOURCE = '/subscriptions'     #/oldest'
    DEFAULT_METHOD =  "-- Select a method to test --"
    METHOD_LIST = [DEFAULT_METHOD, "GET", "POST", "PUT", "DELETE"]

    def new
        logger.debug("'new' method called in #{self.controller_name}")

        @web_service_test = WebServiceTest.new

        @web_service_test.name = "WST-" + DateTime::now.strftime("%I:%M:%S %p")
        @web_service_test.test_method =
        @web_service_test.server = DEFAULT_SERVER
        @web_service_test.resource = DEFAULT_RESOURCE

        @test_method_list = METHOD_LIST
        @test_response = session[:test_response] ||= {response_text: "will go here ..."}
    end

    def create
        logger.debug("'create' method called in #{self.controller_name}")
        #wst = WebServiceTest.new(params[:web_service_test])
        @web_service_test = WebServiceTest.new(params[:web_service_test])

        if @web_service_test.valid?

            # HERE IT IS, the REMOTE CALL!
            begin
                test_response = make_request(@web_service_test)
            rescue => ex
                form_init
                @connection_error = "#{ex.class}: #{ex.message}"
                render 'new'
                return
            end

            # Pass it across the redirect - TODO:  figure if there's another way
            session[:test_response] = test_response
            #{response_text: DateTime::now.seconds_since_midnight.to_s + ":  hard-coded response;  would send, recieve, and update this text ..."}

            # Add some explanation for bad status codes
            if test_response.status != 200
                form_init
                @soft_connection_error = test_response.status.to_s + ":  " + @error_message
                render 'new'
                return
            else
                @web_service_test.status = test_response.status

                if params[:db_save] == "on"
                    logger.debug("saving this WST:  " + @web_service_test.to_s)
                    # NOTE:  if saved, form wants to "PUT" next request, so need "UPDATE" method, yada yada
                    @web_service_test.save
                end

                # wish we could ...
                # render 'new'
                # but routing problems ... TODO - full Rails way
                redirect_to new_web_service_test_path()
            end
        else
            form_init
            # If we did this direct render call, we would have to set up all the default form values;  BUT!
            # We can't do this, as it forces a call to the 'update' method in the controller *iff* the database was written
            render 'new'
        end
    end

    private
        def form_init
            @test_method_list = METHOD_LIST #[DEFAULT_METHOD, "GET", "PUT"]
            @test_response = session[:test_response] ||= {response_text: "will go here ..."}
            @connection_error = nil
            @soft_connection_error = nil
        end

        # TODO: try setting some header info for the request type instead of just hammering the file suffix to the mime type
        #
        def make_request(in_web_service_test)

            # create the target URI
            #
            case in_web_service_test.mime_type
                when "json"
                    suffix = '.json'
                when "xml"
                    suffix = '.xml'
                else
                    raise ArgumentError, "select a supported mime type"
            end

            url = URI.parse(in_web_service_test.server + in_web_service_test.resource + suffix)

            # create the proper request
            case in_web_service_test.test_method
                when 'GET'
                    req = Net::HTTP::Get.new(url.path)
                when 'POST'
                    raise ArgumentError, "POST not supported"
                    # TODO need text input for the POST (or PUT) payload
                when 'PUT'
                    raise ArgumentError, "PUT not supported"
                when 'DELETE'
                    req = Net::HTTP::Delete.new(url.path)
                        #Get.new(url.path)
                else
                    raise ArgumentError, "select a supported method to test"
            end

            # doc note: When called with a block, passes an HTTPResponse object to the block.
            # The body of the response will not have been read yet;
            # the block can process it using Net::HTTPResponse#read_body, if desired.
            #
            res = Net::HTTP.start(url.host, url.port) { |http|
                http.request(req)
            }

            raw_response = res.body

            #response_product = JSON(res.body)["product"]
            #json_parsed_response = JSON.parse res.body
            #logger.debug("JSON RESPONSE:  " + json_parsed_response.to_s)

            # alloc and init a test_response resource
            test_response = TestResponse.new
            test_response.status = res.code
            test_response.response_text = in_web_service_test.name + ":\n" +  raw_response.to_s #for now;  TODO clean this up, parse, extract, etc.
            #DateTime::now.seconds_since_midnight.to_s + ":  "

            #hack return extra stuff;  many other success code, so there's got to be a Rails way for this
            @error_message = res.message

            return test_response
        end
end
