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
    
    def has_access?(ontology)
      return true if ontology.useracl.nil? || ontology.useracl.empty?
      
      ontology.useracl.each do |user|
        return true if user.to_i == self.id.to_i
      end
      
      return false
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
      self.apikey = params[:apikey]
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
      params[:apikey] = self.apikey
      return params
    end

    
end