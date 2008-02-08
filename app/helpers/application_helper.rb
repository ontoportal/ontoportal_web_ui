 # Methods added to this helper will be available to all templates in the application.

require 'uri'
module ApplicationHelper
  
  
  def encode_param(string)
    return URI.escape(string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end
  
  def clean(string)
    string = string.gsub("\"",'\'')
    return string.gsub("\n",'')
  end
  
  def to_param(string)
     "#{encode_param(string.gsub(" ","_"))}"
  end
  
  def draw_note_tree(notes,key)
    output = ""
    draw_note_tree_leaves(notes,0,output,key)
    return output
  end
  
  def remove_owl_notation(string)    
    strings = string.split(":")
    if strings.size<2
      return string.titleize
    else  
      return strings[1].titleize
    end
  end
  
  
  def draw_note_tree_leaves(notes,level,output,key)

  for note in notes
    name="Anonymous"
    unless note.user.nil?
      name=note.user.user_name
    end
  headertext=""
  notetext=""
  if note.note_type.eql?(5)
    headertext<< "<div class=\"header\" onclick=\"toggleHide('note_body#{note.id}','hiddenNote');compare('#{note.id}')\">"
    notetext << " <input type=\"hidden\" id=\"note_value#{note.id}\" value=\"#{note.comment}\"> 
                  <span class=\"message\" id=\"note_text#{note.id}\">#{note.comment}</span>"
  else
    headertext<< "<div class=\"header\" onclick=\"toggleHide('note_body#{note.id}','hiddenNote')\">"
    
    notetext<< "<span class=\"message\" id=\"note_text#{note.id}\">#{simple_format(note.comment)}</span>"
  end
  
  
    output << "
        <div style=\"clear:both;margin-left:#{level*20}px;\">
        <div class=\"ygtvln\" style=\"float:left;\"></div>
        <div class=\"outgoing\" style=\"float:left;width:500px;\">  
          
          <div class=\"header_top\"></div>
          #{headertext}
            <div>
              <div><span class=\"sender\" style=\"float:right\">#{name} at #{note.created_at.strftime('%m/%d/%y %H:%M')}</span>
                <div class=\"sender\">#{note.type_label.titleize}: #{note.subject}</div>
              </div>
            </div>
            <div class=\"left\"></div>
            <div class=\"right\"></div>
          </div>
        
          <div name=\"hiddenNote\" id=\"note_body#{note.id}\" style=\"display:none;\">
          <div class=\"messages\">
            <div>
              <div>
               #{notetext}"
               if session[:user].nil?
                 output << "<div id=\"insert\"><a href=\"\/login?redirect=#{@ontology.to_param}\">Reply</a></div>"
               else
                output << "<div id=\"insert\"><a href=\"\#\" onclick =\"buildEditor('#{key}');toggleHide('form','');toggleHide('buttons','');document.getElementById('noteParent').value='#{note.id}'\">Reply</a></div>"
               end
   output << "</div>
            </div>
          </div>
          <div class=\"messages_bottom\">
            <div class=\"left\"></div>
            <div class=\"right\"></div>
          </div>
          </div>
        </div>
        </div>"
        if(!note.children.nil? && note.children.size>0)
          draw_note_tree_leaves(note.children,level+1,output,key)
        end
    end
    
    
  end
  
  
  
  
  
  def draw_tree(root, id=nil,type="Menu")
    string =""  
    if id.nil?
      id = root.children.first.id
    end
    
      build_tree(root,nil,string,id)
    
    
    return string
  end

  def build_tree(node,parent,string,id)
    if parent.nil?
      parent = 'root'
    end
    unless node.children.nil? || node.children.length <1
      for child in node.children
      icons = ""
      if(child.note_icon)
        icons << "<img src='/images/notes_icon.png'style='vertical-align:bottom;' title='Concept Has Margin Notes'>"
      end
      if(child.map_icon)
        icons << "<img src='/images/map_icon.png' style='vertical-align:bottom;' title='Concept Has Mappings'>"
      end
    
      
        string <<"var myobj = \{ label: \"#{child.name} #{icons}\", id:\"#{child.id}\",href:\"javascript:onClickTreeNode('#{child.id}','#{child.name}')\" \};\n
    		   		    var Node#{child.id.to_s.gsub(":","")} = new YAHOO.widget.MenuNode(myobj, #{parent}, #{child.expanded});\n"
    		   		
    				if child.child_size>0 && !child.expanded
    				  string << "Node#{child.id.gsub(":","")}.setDynamicLoad(loadNodeData);\n"
  				  end

    				
    				if child.id.eql?(id)
    				 string<< "Node#{child.id.gsub(":","")}.labelStyle=\"ygtvlabel-selected\"\n";	
    				end
    				    				build_tree(child,"Node#{child.id.to_s.gsub(":","")}",string,id)
      
      end
      
    end
        
  end
  
end
