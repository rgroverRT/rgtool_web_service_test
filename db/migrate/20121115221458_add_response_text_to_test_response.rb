class AddResponseTextToTestResponse < ActiveRecord::Migration
  def change
    add_column :test_responses, :response_text, :string
  end
end
