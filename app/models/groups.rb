class Groups

  attr_accessor :group_list
  
  def to_a
    groups_array = []
    self.group_list.each do |group_id, group|
      groups_array << group
    end
    
    groups_array.sort! {|a,b| a[:name] <=> b[:name]}
    
    groups_array
  end
end
