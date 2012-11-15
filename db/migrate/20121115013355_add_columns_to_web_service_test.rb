class AddColumnsToWebServiceTest < ActiveRecord::Migration
  def change
    add_column :web_service_tests, :server, :string
    add_column :web_service_tests, :resource, :string
  end
end
