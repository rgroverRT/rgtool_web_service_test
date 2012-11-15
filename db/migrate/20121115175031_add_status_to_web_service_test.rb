class AddStatusToWebServiceTest < ActiveRecord::Migration
  def change
    add_column :web_service_tests, :status, :integer
  end
end
