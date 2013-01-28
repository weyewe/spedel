require 'spec_helper'

describe Customer do
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
    
    @public_calling_number  = '082125573759'
    @name  = 'Otong'
    @customer = Customer.create_by_employee(@admin,  false, {
      :name           => @name,
      :phone => @public_calling_number
    }) 
  end
  
  it 'should create customer' do 
    @customer.should be_valid 
    @customer.calling_numbers.count.should == 1 
  end
  
  it 'should not create customer if either name or phone is blank' do
    @customer = Customer.create_by_employee(@admin,  false, {
      :name           => ' ',
      :phone => @public_calling_number
    })
    
    @customer.should_not be_valid 
    
    @customer = Customer.create_by_employee(@admin,  false, {
      :name           => @name,
      :phone =>  ' '
    })
    
    @customer.should_not be_valid 
  end
  
  it 'should produce calling number with status :main' do
    @customer.reload 
    @calling_numbers = @customer.calling_numbers
    @calling_numbers.length == 1 
    @calling_numbers.first.case.should == CALLING_NUMBER_CASE[:main]
  end
  
  context "updating the phone number" do
    before(:each) do 
      @second_name = "BBBB"
      @second_phone = "33333"
      @customer.update_by_employee( @admin, {
        :name => @second_name,
        :phone => @second_phone 
      }) 
    end
    
    it 'should update the calling number' do
      @customer.reload 
      
      @customer.phone ==  @second_phone
      @main_calling_number = @customer.main_calling_number
      @main_calling_number.reload 
      
      @main_calling_number.number.should ==   @second_phone
    end
  end
  
end
