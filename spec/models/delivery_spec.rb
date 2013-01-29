require 'spec_helper'


# this is for the normal public customer.. just to ensure that there is parts that works :) 
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
    
    @corporate_customer = Customer.create_by_employee(@admin, true, {
      :name => "Indofood",
      :phone => "77777"
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
    
  end # end of before(:each)
  
  
  # create Delivery
  # assign employee 
  # update pickup time 
  # update delivery time
  # update approval => upon approval => eligible for comission  # still can change employee
  
  # update employee name 
  
  
  
  it 'should create delivery scenario for all possible routes' do
    @delivery_scenarios.count.should == @total_scenarios.count 
  end
  
  it 'should give each delivery scenario a price' do
    @delivery_scenarios.each do |ds|
      ds.public_price.should be_valid 
    end
  end
  
  it 'should create Delivery' do
    delivery = Delivery.create_by_employee( @admin, {
      :delivery_scenario_id => @first_ds.id , 
      :customer_id => @customer.id ,
      :pickup_address => "This is the awesome pickup address", 
      :delivery_address => "This is the awesome delivery address",
      :discount => '0'
    })
    
    delivery.should be_valid 
  end
  
  it 'should not allow discount larger than 100' do
    delivery = Delivery.create_by_employee( @admin, {
      :delivery_scenario_id => @first_ds.id , 
      :customer_id => @customer.id ,
      :pickup_address => "This is the awesome pickup address", 
      :delivery_address => "This is the awesome delivery address",
      :discount => '100'
    })
    
    delivery.should be_valid
    
    delivery = Delivery.create_by_employee( @admin, {
      :delivery_scenario_id => @first_ds.id , 
      :customer_id => @customer.id ,
      :pickup_address => "This is the awesome pickup address", 
      :delivery_address => "This is the awesome delivery address",
      :discount => '101'
    })
    
    delivery.should_not be_valid
  end
  
  context "checking delivery post creation condition" do
    before(:each) do
      @delivery = Delivery.create_by_employee( @admin, {
        :delivery_scenario_id => @first_ds.id , 
        :customer_id => @customer.id ,
        :pickup_address => "This is the awesome pickup address", 
        :delivery_address => "This is the awesome delivery address",
        :discount => '0'
      })
    end
    
    it 'should create delivery' do
      @delivery.should be_valid 
    end
    
    it 'should produce the correct amount' do
      @delivery.amount.should == @first_ds.public_price.price  
    end
  end
  
  context "checking delivery with discount" do 
    before(:each) do
      @discount = 10
      @delivery = Delivery.create_by_employee( @admin, {
        :delivery_scenario_id => @first_ds.id , 
        :customer_id => @customer.id ,
        :pickup_address => "This is the awesome pickup address", 
        :delivery_address => "This is the awesome delivery address",
        :discount => @discount.to_s
      })
    end
    
    it 'should be valid' do
      @delivery.should be_valid
    end
    
    it 'should produce the correct amount, taking input from the discount' do
      public_price = @first_ds.public_price.price
      public_price_after_discount =    (100-@discount.to_f)*public_price/100.to_f
      @delivery.amount.should ==  public_price_after_discount
    end
    
    it 'should allow update' do
      @delivery.update_by_employee(@admin, {
        :delivery_scenario_id => @first_ds.id , 
        :customer_id => @second_customer.id ,
        :pickup_address => "This is the awesome pickup address", 
        :delivery_address => "This is the awesome delivery address",
        :discount => @discount.to_s
      })
      @delivery.should be_valid 
      
      @delivery.customer_id.should == @second_customer.id 
    end
    
    it 'should update price on delivery scenario update' do
      
      @delivery.update_by_employee(@admin, {
        :delivery_scenario_id =>  @second_ds.id , 
        :customer_id => @second_customer.id ,
        :pickup_address => "This is the awesome pickup address", 
        :delivery_address => "This is the awesome delivery address",
        :discount => @discount.to_s
      })
      @delivery.should be_valid
      
      public_price = @second_ds.public_price.price
      public_price_after_discount =    (100-@discount.to_f)*public_price/100.to_f
      @delivery.amount.should ==  public_price_after_discount
    end
    
    it 'should update price on discount update' do
      @new_discount = 20 
      @delivery.update_by_employee(@admin, {
        :delivery_scenario_id =>  @second_ds.id , 
        :customer_id => @second_customer.id ,
        :pickup_address => "This is the awesome pickup address", 
        :delivery_address => "This is the awesome delivery address",
        :discount => @new_discount.to_s
      })
      @delivery.should be_valid
      
      public_price = @second_ds.public_price.price
      public_price_after_discount =    (100-@new_discount.to_f)*public_price/100.to_f
      @delivery.amount.should ==  public_price_after_discount
    end 
  end # "checking delivery post creation condition"
  
  
  
  # delivery progress: 
  # 1. pick up
  # 2. delivery 
  # 3. approved   => pass the receipt 
  # 4. paid  => pass the $$  # if instant delivery, automatically mark as paid . 
  # 5. CANCELed 
  context "update delivery progress" do
    context "finalize delivery : through approval" do
      context "public delivery"
      
      context "corporate delivery: the payment is flexible, can be monthly or weekly"
    end
    
    context "finalize delivery: through cancelation"
  end   # => "update delivery progress"   
  
  
end
  
  
  

