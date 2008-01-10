module ConceptsHelper
   

  def drawResourceTable(resources)
      html = "<table class=\"resources\" cellpadding=0 cellspacing=0>\n"
      
    nodes =[]
    list_index =0
    
    while list_index < resources.size
      resource = resources.get(list_index)
      annotations = resource.getLineAnnotations
      
      if annotations.size >0
        html << "<tr class=\"mainresource\" onclick = \"toggleHide('annotation#{list_index}','annotations')\">\n"
      else
        html << "<tr class=\"mainresource\">\n"
      end
      
      html << "<td><img src=\"#{resource.getLineLogo()}\"><br>#{resource.getLineName}</td><td>#{resource.getLineDescription}</td><td>Elements:#{resource.getLineNumber}</td>"
      html << "</tr>"
      
      annotations_index = 0
    
      if annotations.size >0
        html << "<tr name = \"annotations\" id = \"annotation#{list_index}\" style=\"display:none;\"><td colspan=3>"
        html << "<table class=\"annotations\" cellpadding=0 cellspacing=0>"
        html << "<tr>
           <th>Element ID</th>
           <th>Annotation Context</th>
           <th>Element Link</th>
         </tr>
           "
        
      end
      
        while annotations_index < annotations.size
        annotation = annotations.get(annotations_index)
          html << "<tr>"
          html <<"<td>#{annotation.getElementLocalID}</td><td>#{annotation.getItenKey}</td><td><a href=\"#{annotation.getUrl.toString}\" target=\"_new\">View Element</a></td>"
          html << "</tr>"
        
        
        
          annotations_index = annotations_index +1
        end
      if annotations.size >0
        html << "</table>"
        html << "</td></tr>"
      end
      
      list_index = list_index+1
    end  
    html <<"</table>"
    return html
  end

  
  
end
