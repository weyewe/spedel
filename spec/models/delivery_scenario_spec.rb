require 'spec_helper'

describe DeliveryScenario do
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
    
    
    # create the delivery scenario => for pricing  DONE 
    @da_array = [@first_da.id , @second_da.id , @third_da.id ]

    different_area_delivery_scenarios = @da_array.combination(2).to_a  
    same_area_delivery_scenarios = @da_array.collect  { |x| [x, x]}

    @total_scenarios = different_area_delivery_scenarios + same_area_delivery_scenarios
    
    # # create pricing => DONE 
    # @total_scenarios.each do |delivery_scenario|
    #   price = count*1000
    #   
    #   Price.create__by_employee( @admin, false, {  # false means that it is not corporate 
    #     :delivery_scenario_id => delivery_scenario.id , 
    #     :price => price.to_s ,
    #     :customer_id => nil 
    #   })
    #   count++  
    # end
  end
  
  it 'should create delivery scenario' do
    ds = DeliveryScenario.create_by_employee(@admin, {
      :source_id => @first_da.id,
      :target_id => @second_da.id
    })
    
    ds.should be_valid 
  end
  
  it 'should not allow duplicate delivery scenario (similar source and target) ' do
    ds = DeliveryScenario.create_by_employee(@admin, {
      :source_id => @first_da.id,
      :target_id => @second_da.id
    })
    
    ds.should be_valid
    
    second_ds = DeliveryScenario.create_by_employee(@admin, {
      :source_id => @first_da.id,
      :target_id => @second_da.id
    })
    
    second_ds.should_not be_valid
  end
  
  
  
   
   
  
end
