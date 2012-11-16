class WebServiceTest < ActiveRecord::Base
    #attr_accessible :name
    #                :mime_type
    #                :test_method
    #                :server
    #                :resource
    validates :server, presence: true
    validates :resource, presence: true
    validate :test_method_must_be_selected, :on => :create

    def test_method_must_be_selected
        if test_method[0] == '-'
            errors.add(:test_method, "must be selected from the list")
        end
    end
end
