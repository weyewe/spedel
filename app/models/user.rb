class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name , :role_id
  # attr_accessible :title, :body
  validates_uniqueness_of :email 
  validates_presence_of :email  , :role_id 
  
  def self.create_main_user(new_user_params) 
    new_user = User.new( :email => new_user_params[:email], 
                            :password => new_user_params[:password],
                            :password => new_user_params[:password_confirmation] )
                      
  
    admin_role = Role.find_by_name ROLE_NAME[:admin]
    new_user.role_id = admin_role.id 
    new_user.is_main_user = true
    
    new_user.save 
  
    return new_user 
  end
  
  def self.active_objects
    self.where(:is_deleted => false).order("created_at DESC")
  end
  
  def delete(employee)
    return nil if employee.nil?
    
    random_password                    = UUIDTools::UUID.timestamp_create.to_s[0..7]
    self.password = random_password
    self.password_confirmation = random_password 
    self.is_deleted = true 
    self.save 
    
  end
  
  def User.create_by_employee( employee, params)
    return nil if employee.nil? 
    
    new_object                        = User.new 
    password                         = UUIDTools::UUID.timestamp_create.to_s[0..7]
    new_object.name                  = params[:name]
    new_object.email                 = params[:email] 
    new_object.role_id               = params[:role_id]
    
    new_object.password              = password
    new_object.password_confirmation = password 
    
    new_object.save

    
     
     
    return new_object 

  end
  
  def update_by_employee( employee, params)
    return nil if employee.nil? 
      
    self.name                  = params[:name]
    self.email                 = params[:email] 
    
    
    if  self.is_main_user == false  
      self.role_id               = params[:role_id]
    end
    
    self.save
    return self  
  end
  
  def update_password(  params) 
    self.password = params[:password]
    self.password_confirmation = params[:password_confirmation]
    
    self.save 
    
    return self 
    
  end
  
  def reset_password( employee, params ) 
    password                   = UUIDTools::UUID.timestamp_create.to_s[0..7]
    self.password              = password
    self.password_confirmation = password 
    
    if self.save
      UserMailer.notify_reset_password( employee, self , password    ).deliver
    end
    
    return self
  end
  
  def set_as_main_user 
    admin_role = Role.find_by_name ROLE_NAME[:admin]
    self.role_id = admin_role.id 
    self.is_main_user = true 
    self.save 
  end
  
end
