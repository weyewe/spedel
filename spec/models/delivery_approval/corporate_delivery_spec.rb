require 'spec_helper'

# gonna test the delivery approval for CORPORATE CUSTOMER  
describe Delivery do
  before(:each) do
    role = {
      :system => {
        :administrator => true
      }
    }

    Role.create!(
    :name        => ROLE_NAME[:admin],
    :title       => 'Administrator',
    :description => 'Role for administrator',
    :the_role    => role.to_json
    )
    @admin_role = Role.find_by_name ROLE_NAME[:admin]
    @admin =  User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
    @company = Company.create(:name => "Spedel JKT", :address => "Tanggerang", :phone => "209834290840932")
    
    @employee_1 = Employee.create_by_employee(@admin, {
      :name => 'Otong sulaiman',
      :mobile_phone => '9183291830',
      :address => 'jalan sitanggang'
    })
    
    @employee_2 = Employee.create_by_employee(@admin, {
      :name => 'Jaka Tingkir',
      :mobile_phone => '324234',
      :address => 'Merpati Putih'
    })
    
    @public_calling_number  = '082125573759'
    @name  = 'Otong'
    @customer = Customer.create_by_employee(@admin,  false, {
      :name           => @name,
      :phone => @public_calling_number
    })
    
    @second_customer = Customer.create_by_employee(@admin,  false, {
      :name           => @name + "hahaha ",
      :phone => @public_calling_number + "u322304"
    })
    
    @corporate_customer_delayed = Customer.create_by_employee(@admin, true, {
      :name => "Indofood",
      :phone => "77777",
      :is_delayed_payment => true 
    })
    
    @corporate_customer_non_delayed = Customer.create_by_employee(@admin, true, {
      :name => "Indofood",
      :phone => "77777",
      :is_delayed_payment => false  
    })
    
    
    
    
    # create the delivery area  => DONE 
    
    @first_da  = DeliveryArea.create_by_employee( @admin, {
      :name => "Tanggerang",
      :company_id => @company.id
    })
    
    @second_da  = DeliveryArea.create_by_employee( @admin, {
      :name => "Cikarang",
      :company_id => @company.id
    })
    
    @third_da  = DeliveryArea.create_by_employee( @admin, {
      :name => "Depok",
      :company_id => @company.id
    })
    
    
    # create the delivery scenario => for pricing  DONE 
    @da_array = [@first_da.id , @second_da.id , @third_da.id ]

    different_area_delivery_scenarios = @da_array.combination(2).to_a  
    same_area_delivery_scenarios = @da_array.collect  { |x| [x, x]}

    @total_scenarios = different_area_delivery_scenarios + same_area_delivery_scenarios
    
    @total_scenarios.each do |x|
      DeliveryScenario.create_by_employee(@admin, {
        :source_id => x.first,
        :target_id => x.last 
      })
    end
    
    @delivery_scenarios = DeliveryScenario.all 
    @first_ds = @delivery_scenarios.first 
    @second_ds = @delivery_scenarios[2]
    # create public pricing => DONE 
    count = 1
    @delivery_scenarios.each do |ds|
      price = count*1000
      
      price = Price.create_by_employee( @admin, false, {  # false means that it is not corporate 
        :delivery_scenario_id => ds.id , 
        :price => price.to_s ,
        :customer_id => nil 
      })
      price.should be_valid 
      count = count+1 
    end
    
    # create corporate pricing 
    count = 1 
    
    @delivery_scenarios.each do |ds|
      price = count*1000
      
      price = Price.create_by_employee( @admin, true, {  # false means that it is not corporate 
        :delivery_scenario_id => ds.id , 
        :price => price.to_s ,
        :customer_id => @corporate_customer_delayed.id  
      })
      price.should be_valid 
      count = count+1 
    end
    
    count = 1 
    
    @delivery_scenarios.each do |ds|
      price = count*1000
      
      price = Price.create_by_employee( @admin, true, {  # false means that it is not corporate 
        :delivery_scenario_id => ds.id , 
        :price => price.to_s ,
        :customer_id => @corporate_customer_non_delayed.id  
      })
      price.should be_valid 
      count = count+1 
    end
    
    
  end # end of before(:each)
 
  context "delayed payment" do
    before(:each) do
      @delivery = Delivery.create_by_employee( @admin, {
        :delivery_scenario_id => @first_ds.id , 
        :customer_id => @corporate_customer_delayed.id ,
        :pickup_address => "This is the awesome pickup address", 
        :delivery_address => "This is the awesome delivery address",
        :discount => '0'
      })

      time = DateTime.now 
      @delivery.update_pickup(@admin, {
        :is_picked_up => true,
        :pickup_time => time
      })

      @delivery.update_delivery(@admin, {
        :is_delivered => true,
        :delivery_time => time
      })
      @delivery.reload
    end
    
    it 'should not mark as paid on delivery' do
      @delivery.assign_employee( @employee_1 )
      
      @delivery.approve( @admin ) 
      @delivery.is_approved.should == true 
      @delivery.approver_id.should == @admin.id

      @delivery.is_paid.should == false 
    end
  end
  
  context "instant payment" do
    before(:each) do
      @delivery = Delivery.create_by_employee( @admin, {
        :delivery_scenario_id => @first_ds.id , 
        :customer_id => @corporate_customer_non_delayed.id ,
        :pickup_address => "This is the awesome pickup address", 
        :delivery_address => "This is the awesome delivery address",
        :discount => '0'
      })
  
      time = DateTime.now 
      @delivery.update_pickup(@admin, {
        :is_picked_up => true,
        :pickup_time => time
      })
  
      @delivery.update_delivery(@admin, {
        :is_delivered => true,
        :delivery_time => time
      })
      @delivery.reload
    end
    
    it 'should not mark as paid on delivery' do
      @delivery.assign_employee( @employee_1 )
      @delivery.approve( @admin ) 
      @delivery.is_approved.should == true 
      @delivery.approver_id.should == @admin.id
  
      @delivery.is_paid.should == true      
    end
  end
  
 
end
  
  
  

