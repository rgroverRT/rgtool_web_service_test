class CreateWebServiceTests < ActiveRecord::Migration
  def change
    create_table :web_service_tests do |t|
      t.string :name

      t.timestamps
    end
  end
end
