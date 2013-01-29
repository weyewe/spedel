class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.integer :creator_id 
      
      t.string :name
      
      t.string :phone 
      
      
      # The following fields are only available on corporate customer 
      # corporate customers: those that are big enough to have discount or negotiate their rate
      # they can even create delivery project: 
      # => 1. big number of supplies. Dispatch it within n days. 
      t.string :contact_person
      t.string :mobile 
      t.string :email 
      t.string :bbm_pin  
      t.text :office_address  
      
      # if it is corporate customer, will have its own pricing.
      # what else? it can create delivery project
      # delivery 1,000 deliveries. 15,000 per delivery. Sweet? of course 
      t.boolean :is_corporate_customer, :default => false 
       
      t.boolean :is_deleted, :default  => false
      
      t.boolean :is_delayed_payment, :default => false 

      t.timestamps
    end
  end
end
