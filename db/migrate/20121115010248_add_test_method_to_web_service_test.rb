class AddTestMethodToWebServiceTest < ActiveRecord::Migration
  def change
    add_column :web_service_tests, :test_method, :string
  end
end
