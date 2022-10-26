#This class holds the team members, the members are nor rows in database since the number is limited
class Team
  #Add team members in 'bioportal_config_*.rb' file
  def self.members
    list = $TEAM_MEMBERS.to_a
    return list
  end

  def self.contributors
    list = $CONTRIBUTORS.to_a
    return list
  end

end

