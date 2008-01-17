require "digest/sha1"
class User< ActiveRecord::Base
  
  attr_accessor :validate_password  
  attr_accessor :password
  
  validates_length_of :password, :if=>:validate_password , :minimum =>8, :too_short=> "Please enter a password 8 characters long"
  validates_uniqueness_of :user_id,:email
  validates_confirmation_of  :password  ,:email
  validates_presence_of :user_id,:email
 
 
 
  def before_update
    unless self.password.nil?
      self.hashed_password = User.hash_password(self.password)
    end
  end
  
  def before_create
    self.hashed_password = User.hash_password(self.password)
  end
  
  def after_create
    @password = nil
  end
  
  def self.login(user_name, password)
    hashed_password = hash_password(password || "")
    find(:first,
         :conditions => ["user_name = ? and hashed_password = ?",
    user_name, hashed_password])
  end
  
  def try_to_login
    User.login(self.user_name, self.password)
  end
  
  def change_password(password)
    self.hashed_password = User.hash_password(password)
  end
  
  
  
 
  
  
  
  #-----------------------------------------------------------
  private
  def self.hash_password(password)
    Digest::SHA1.hexdigest(password)
  end
  
  
  end