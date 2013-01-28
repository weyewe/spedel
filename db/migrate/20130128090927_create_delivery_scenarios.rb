class CreateDeliveryScenarios < ActiveRecord::Migration
  def change
    create_table :delivery_scenarios do |t|
      t.integer :company_id 
      t.integer :creator_id 
      
      t.integer :source_id 
      t.integer :target_id 
      # price info is stored in the public price 
      
      # t.decimal :price         , :precision => 9, :scale => 2 , :default => 0  # 10^7 

      t.timestamps
    end
  end
end
