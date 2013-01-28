class CreateDeliveryAreas < ActiveRecord::Migration
  def change
    create_table :delivery_areas do |t|
      t.integer :creator_id 
      
      t.integer :company_id 
      
      
      t.string :name 
      
      

      t.timestamps
    end
  end
end
