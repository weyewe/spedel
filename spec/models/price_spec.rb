require 'spec_helper'
 
describe Price do
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
    
    @first_ds = DeliveryScenario.first 
    @delivery_scenarios = DeliveryScenario.all 
  end
  
  it 'should create price for the scenario' do
    # aa bb cc , ab ac bc 
    @total_scenarios.length.should == 6 
  end
  

   
  it 'should not create price if amount == 0 ' do 
    price_amount = "0"
    price = Price.create_by_employee( @admin, false,  {
      :delivery_scenario_id => @first_ds.id , 
      :price => price_amount ,
      :customer_id => nil 
    })
    
    price.should_not be_valid 
  end 
  
  it 'should create price if amount > 0 ' do 
    price_amount = "0"
    price = Price.create_by_employee( @admin, false,  {
      :delivery_scenario_id => @first_ds.id , 
      :price => '60000' ,
      :customer_id => nil 
    })
    
    price.should be_valid
    price.company_id.should == Company.first.id 
  end
  
  it 'should create corporate price if amount > 0 ' do 
    price = Price.create_by_employee( @admin, true,  {
      :delivery_scenario_id => @first_ds.id , 
      :price => '60000' ,
      :customer_id => @corporate_customer.id  
    })
    
    price.should be_valid
    price.company_id.should == @company.id 
    price.customer_id.should == @corporate_customer.id 
  end
  
  it 'should create price for all delivery_scenario' do
    count = 1 
    @delivery_scenarios.each do |ds|
      price = count*1000
      
      price = Price.create_by_employee( @admin, false, {  # false means that it is not corporate 
        :delivery_scenario_id => ds.id , 
        :price => price.to_s ,
        :customer_id => nil 
      })
      
      if price.errors.size != 0 
        puts "THERE IS THE ERROR\n"*5
        price.errors.messages.each do |msg|
          puts "The message: #{msg}" 
        end
      end
      price.should be_valid 
      count = count+1
    end
  end
  
  context "updating the price" do
    before(:each) do
      @initial_price_amount = '60000'
      @initial_price = Price.create_by_employee( @admin, false,  {
        :delivery_scenario_id => @first_ds.id , 
        :price => @initial_price_amount ,
        :customer_id => nil 
      })
    end
    
    it 'should  create a new price if amount == initial' do
      @price = Price.current_active_price( nil, @first_ds.id )
      
      @final_price = Price.create_by_employee( @admin, false,  {
        :delivery_scenario_id => @first_ds.id , 
        :price => @initial_price_amount ,
        :customer_id => nil 
      })
      
      @final_price = Price.current_active_price( nil, @first_ds.id )
      
      @price.id.should_not == @final_price.id 
      
      @final_price.should be_valid 
    end
    
  end
   
  
end
