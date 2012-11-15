class CreateTestResponses < ActiveRecord::Migration
  def change
    create_table :test_responses do |t|
      t.integer :status

      t.timestamps
    end
  end
end
