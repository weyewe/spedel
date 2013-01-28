class Customer < ActiveRecord::Base
  validates_presence_of  :name , :phone 
  has_many :calling_numbers 
  
   
  
  def self.create_by_employee( employee, is_corporate,  params ) 
    return nil if employee.nil? 
    
    new_object = self.new
    new_object.creator_id = employee.id 
    new_object.name       = params[:name]
    new_object.phone      = params[:phone] 
    
    
    if is_corporate 
      new_object.contact_person = params[:contact_person] 
      new_object.mobile         = params[:mobile]         
      new_object.email          = params[:email]          
      new_object.bbm_pin        = params[:bbm_pin]        
      new_object.office_address = params[:office_address]  
      new_object.is_corporate   = is_corporate 
    end
    
    

    
    
    if new_object.save 
      new_object.generate_main_calling_number 
    end
    
    return new_object 
  end
  
  def update_by_employee( employee, params ) 
    return nil if employee.nil? 
    
    self.creator_id = employee.id 
    self.name       = params[:name]
    self.phone      = params[:phone] 
    
    if self.is_corporate_customer? 
      self.contact_person   = params[:contact_person] 
      self.mobile           = params[:mobile]         
      self.email            = params[:email]          
      self.bbm_pin          = params[:bbm_pin]        
      self.office_address   = params[:office_address]  
    end
    
    if self.save 
      self.update_main_calling_number 
    end
    
    return self 
  end
  
  def generate_main_calling_number
    main_calling_numbers = self.calling_numbers.where(:case => CALLING_NUMBER_CASE[:main])
    if main_calling_numbers.length == 0 
      employee = User.find_by_id self.creator_id 
      CallingNumber.create_main_number_by_employee( employee, self, {
        :number  => self.phone 
      })
    end
  end
  
  def update_main_calling_number
    puts "In update main calling number\n"*10
    main_calling_numbers = self.calling_numbers.where(:case => CALLING_NUMBER_CASE[:main])
    employee = User.find_by_id self.creator_id 
    if main_calling_numbers.length == 0 
      
      CallingNumber.create_main_number_by_employee( employee, self, {
        :number  => self.phone 
      })
    else 
      puts "The result: there is calling number"
      main_calling_number  = main_calling_numbers.first 
      return nil if main_calling_number.number  == self.phone 
      puts "Gonna update main calling number"
      main_calling_number.update_by_employee( employee,   {
        :number => self.phone   
      } ) 
    end
  end
  
  
  def main_calling_number
    self.calling_numbers.where(:case => CALLING_NUMBER_CASE[:main]).first 
  end
  
  
end
