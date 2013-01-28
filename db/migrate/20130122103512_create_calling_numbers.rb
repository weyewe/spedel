class CreateCallingNumbers < ActiveRecord::Migration
  def change
    create_table :calling_numbers do |t|
      t.integer :creator_id 
      
      t.string :number
      t.integer :customer_id 
      
      t.integer :case , :default => CALLING_NUMBER_CASE[:main]

      t.timestamps
    end
  end
end
