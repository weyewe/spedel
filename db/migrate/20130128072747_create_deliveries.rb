class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.string :code  
      t.integer :company_id  #which company or office that created this? 
      t.integer :creator_id 
      t.integer :customer_id
      
      # ONLY FOR PROJECT_BASED DELIVERY
      t.integer :project_id , :default => nil 
      t.integer :drop_center_id , :default => nil 
       
      t.integer :case , :default => DELIVERY_CASE[:normal] # can be project 
      
      t.integer :delivery_scenario_id 
      
      # extract the price for a given delivery scenario
      t.integer :price_id 
      t.decimal :discount , :precision => 5, :scale => 2 , :default => 0  # 100% max 
      t.text :discount_note 
      
      # the charged amount  # (100-discount) * base_price 
      t.decimal :amount   , :precision => 9, :scale => 2 , :default => 0  # 100% max  


      # employee needs this for bonus purposes 
      t.integer :employee_id 
      t.text :pickup_address
      t.text :delivery_address 

      # tracking the delivery_progress
      t.boolean :is_picked_up, :default => false 
      t.datetime :pickup_time 
      
      t.boolean :is_delivered, :default => false 
      t.datetime :delivery_time 
      
      t.boolean :is_approved, :default => false 
      t.datetime :approval_time 
      
      
      # FINALIZING delivery can happen in 2 ways: approved => that the delivery is done, or it is cancelled
      # approval means: the employee has the right to get comission. the customer is well served 
      t.boolean :is_approved, :default => false
      t.integer :approver_id 
      t.datetime :approved_at 
      t.boolean :is_canceled , :default => false
      t.integer :cancel_case , :default => DELIVERY_CANCEL_CASE[:phone_cancel]
      t.text :cancel_note 
      
      # has the delivery paid? we must cater to customer that wants to pay per delivery, 
      # or monthly payment. => monthly payment option is for corporate customer 
      
      t.boolean :is_paid, :default => false 
      t.integer :payment_approver_id 
      

      

      t.timestamps
    end
  end
end
