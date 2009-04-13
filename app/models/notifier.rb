class Notifier < ActionMailer::Base
  
  
  
  def signup(user)
    
  end
  
  def lost_password( user,password )
    # Email header info MUST be added here
    recipients user.email
    from  "admin@bioontology.org"
    subject "Password Reset"
  
    # Email body substitutions go here
    body :user=> user, :password=>password
  end
  
  def error(error)
    
    recipients "ngriff@stanford.edu"
    from "admin@bioontology.org"
    subject "Exception Mailer"
    body :exception_message => error.message, :trace => error.backtrace
    
  end
  
  def endlessloop(node)
    recipients "ngriff@stanford.edu"
    from "admin@bioontology.org"
    subject "Exception Mailer"
    body :node => node.inspect
    
    
    
  end
  
  def feedback(name,email,comment)
    recipients "bioontology-support@mailman.stanford.edu,#{email}"
    from "admin@bioontology.org"
    subject "Feedback"
    body :name => name, :email=>email,:comment=>comment
    
    
    
  end
  
  
end
