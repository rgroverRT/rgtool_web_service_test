class AddMimeTypeToWebServiceTest < ActiveRecord::Migration
  def change
    add_column :web_service_tests, :mime_type, :string
  end
end
