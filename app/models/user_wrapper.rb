class UserWrapper

    attr_accessor :id
    attr_accessor :username
    attr_accessor :email
    attr_accessor :firstname
    attr_accessor :lastname
    attr_accessor :roles
    attr_accessor :phone
    attr_accessor :apikey
    attr_accessor :acl
    attr_accessor :owns

    # Used in user forms
    attr_accessor :password_confirmation
    attr_accessor :password
    attr_accessor :email_confirmation
    attr_accessor :validate_password
    attr_accessor :ontologylicensetext
    attr_accessor :ontologylicense

    ROLES = {
      "ROLE_DEVELOPER"=>1,
      "ROLE_LIBRARIAN"=>2,
      "ROLE_ADMINISTRATOR"=>3
    }

    def to_param
      return self.id.to_s
    end

    def admin?
      self.roles.include?("ROLE_ADMINISTRATOR")
    end

    def has_access?(ontology)
      return true if !ontology.viewing_restricted?
      return true if self.admin?

      ontology.useracl.each do |user|
        return true if user.to_i == self.id.to_i
      end

      return false
    end

    def initialize(hash = nil, params = nil)
      return if hash.nil?

      # We can get user information in two contexts, this handles the XML returned when authenticating
      if hash.key?("userBean") && hash.key?("apiKey")
        self.apikey = hash["apiKey"]
        hash = hash["userBean"]
      end

      hash = hash["userBean"] if hash.key?("userBean")

      self.id = hash["id"]
      self.username = hash["username"]
      self.email = hash["email"]
      self.firstname= hash["firstname"]
      self.lastname = hash["lastname"]
      self.roles = hash["roles"]
      self.phone = hash["phone"]
      self.apikey = hash["apikey"] if self.apikey.nil?

      self.roles = []
      if hash["roles"].kind_of?(Array)
        self.roles = hash["roles"]
      else
        self.roles << hash["roles"]
      end

      self.acl = []
      self.owns = []
      if hash["ontologyAcl"]
        hash["ontologyAcl"].each do |key, ont|
          self.acl << ont["ontologyId"].to_i
          self.owns << ont["ontologyId"].to_i if ont["isOwner"].eql?("true")
        end
      end
    end

    def from_params(params={})
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
      params[:ontologylicensetext] = self.ontologylicensetext
      params[:ontologylicense] = self.ontologylicense
      return params
    end


end
