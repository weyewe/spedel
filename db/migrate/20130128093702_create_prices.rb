class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :company_id 
      t.integer :delivery_scenario_id 
      
      t.boolean :is_active, :default => true 
      
      # if it has customer id, it means that the price == corporate price 
      # if nil, price == public price. anybody that calls will be quoted with this price
      t.integer :customer_id, :default => nil 
      
       t.decimal :price         , :precision => 9, :scale => 2 , :default => 0  # 10^7 
       
      t.timestamps
    end
  end
end
