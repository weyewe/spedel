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
admin_role = Role.find_by_name ROLE_NAME[:admin]
first_role = Role.first

company = Company.create(:name => "Super metal", :address => "Tanggerang", :phone => "209834290840932")
admin = User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 

customer_1 = Customer.create_public_customer(@admin, {
  :name => "Dixzell",
  :phone => "082125573759"
}) 
customer_2 = Customer.create_public_customer(@admin, {
  :name => "Custom2",
  :phone => "0856993385"
})

corp_customer_1  = Customer.create_corporate_customer( @admin, {
  :name => "Awesome Corporate Customer"
})

corp_customer_1.register_phone_number('082155585758')
corp_customer_1.register_phone_number('0821555555')
corp_customer_1.register_phone_number('54583784')

joko = Employee.create(   :name => "Joko"  )  
joni = Employee.create(   :name => "Joni" ) 

# SOP to create new company
# 1. create delivery area
# 2. create pricing for each combination of delivery area 

delivery_area_1 = DeliveryArea.create_by_employee(@admin, {
  :name => "Jakarta",
  :company_id => company.id 
})

delivery_area_2 = DeliveryArea.create_by_employee(@admin, {
  :name => "Tanggerang",
  :company_id => company.id 
})

delivery_area_3 = DeliveryArea.create_by_employee(@admin, {
  :name => "Depok",
  :company_id => company.id 
})

# http://chriscontinanza.com/2010/10/29/Array.html << to generate all possible delivery scenarios
=begin
a = ['a','b', 'c']

different_area_delivery_scenarios = a.combination(2).to_a  
same_area_delivery_scenarios = a.collect  { |x| [x, x]}

total_scenarios = different_area_delivery_scenarios + same_area_delivery_scenarios
# give price to each of these scenarios 
=end 
count = 1 
company.delivery_scenarios.each do |delivery_scenario|
  price = count*1000
  delivery_scenario.set_price(  @admin, price.to_s  )
  
  # Price.create_by_employee( @admin, {
  #   :delivery_scenario_id => delivery_scenario.id , 
  #   :price => price.to_s ,
  #   :customer_id => nil 
  # })
  count++ 
  # create public pricing for delivery scenario 
end


count = 1 
company.delivery_scenarios.each do |delivery_scenario|
  price = count*1000
  
  Price.create_corporate_price( @admin, {
    :delivery_scenario_id => delivery_scenario.id , 
    :price => price.to_s ,
    :customer_id => corp_customer_1.id 
  })
  # delivery_scenario.set_corporate_price( @admin, corp_customer_1, price.to_s )
  # CorporatePricing.create_by_employee(@admin, corp_customer_1, {
  #   :price => price.to_s ,
  #   :delivery_scenario_id => delivery_scenario.id 
  # })
  count++ 
end

west_dc = DropCenter.create_by_employee( @admin, company, {
  :name => "West Jakarta"
})

north_dc = DropCenter.create_by_employee( @admin, company, {
  :name => "North Jakarta"
})

east_dc = DropCenter.create_by_employee( @admin, company, {
  :name => "East Jakarta"
})

central_dc = DropCenter.create_by_employee( @admin, company, {
  :name => "Central Jakarta"
})
 


delivery = Delivery.create_pick_and_deliver_by_employee( admin, customer_1 , {
  :source_address => 'Ratu Plaza Lantai 14',
  :source_area =>  delivery_area_1.id , 
  :destination_address => 'Ratu Atut Tanggerang Sejati',
  :destination_area => delivery_area_2.id , 
  :drop_center_id => nil 
  :discount => nil # how many percent? => for subsequent delivery  # default => 0 % 
})
# price will be deduced inside


delivery.assign_driver_by_employee(@admin, joko)  # pending driver is not true anymore upon assignment.. status == on pickup

delivery.confirm_pickup( @admin )  # status == on delivery 
# if there is no shite to be picked up.. close delivery.. , mark as no pickup 

delivery.confirm_delivery( @admin ) # status == delivery done , item is passed to destination 
# if there is no receiver, return the delivery. Mark this delivery cnfirmation as no receiver 


#delivery.cancel_delivery(@admin) => if the guy called, and cancelled. 

# if they don't confirm pickup & delivery, but confirm approval => auto confirm pickup and delivery
delivery.confirm_approval( @admin ) # status == delivery done , cashier receive the proof of delivery  + $$$ for non corporate delivery



# the customer is always corporate customer 
# the pricing is per mail sent 
project = Project.create_by_employee(@admin, corp_customer_1, {
  :is_fixed_price     => true, 
  :price_per_delivery => '15000'
})

delivery_from_dc = Delivery.create_delivery_from_drop_center_by_employee( admin, project , {
  :source_address      => 'Ratu Plaza Lantai 14',
  :source_area         =>  delivery_area_1.id , 
  :destination_address => 'Ratu Atut Tanggerang Sejati',
  :destination_area    => delivery_area_2.id , 
  :drop_center_id      => east_dc.id    
})
 













