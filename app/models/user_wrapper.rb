class UserWrapper
  

    attr_accessor :id
    attr_accessor :username
    attr_accessor :email
    attr_accessor :firstname
    attr_accessor :lastname
    attr_accessor :display_label
    attr_accessor :roles
    attr_accessor :phone
    attr_accessor :session_id
    
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

    
end