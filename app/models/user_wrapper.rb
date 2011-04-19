class UserWrapper

    attr_accessor :id
    attr_accessor :username
    attr_accessor :email
    attr_accessor :firstname
    attr_accessor :lastname
    attr_accessor :roles
    attr_accessor :phone
    attr_accessor :apikey
    
    attr_accessor :password_confirmation  
    attr_accessor :password
    attr_accessor :email_confirmation    
    attr_accessor :validate_password
    
    ROLES = {
      "ROLE_DEVELOPER"=>1,
      "ROLE_LIBRARIAN"=>2,
      "ROLE_ADMINISTRATOR"=>3
    }
    
    def to_param
      return self.id.to_s
    end
    
    def admin?
      if self.roles.include?("ROLE_ADMINISTRATOR")
        return true
      else
        return false
      end
    end
    
    def initialize(params={})
      self.id = params[:id]
      self.username = params[:username]
      self.email = params[:email]
      self.firstname= params[:firstname]
      self.lastname = params[:lastname]
      self.roles = params[:roles]
      self.phone = params[:phone]
      self.email_confirmation = params[:email_confirmation]
      
    end
    
    def to_h
      params={}
      params[:id]= self.id
      params[:username] = self.username 
      params[:email] = self.email
      params[:firstname] = self.firstname
      params[:lastname] =  self.lastname 
      params[:roles] = self.roles
      params[:phone] = self.phone
      params[:password]= self.password
      return params
    end

    
end