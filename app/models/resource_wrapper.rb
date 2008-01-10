

class ResourceWrapper

  
  def foo(keyword,ontology) 
   
    
   @obsresult = Rjb::import('obs.user.OBSResult')
   result = @obsresult.new(ontology,keyword)
   
   puts result.getResultLines.size;
   
   list_index =0
    
    while list_index < result.getResultLines.size
      resource = result.getResultLines.get(list_index)
      annotations_index = 0;
       while annotations_index < resource.getLineAnnotations.size
        annotation = resource.getLineAnnotations.get(annotations_index)
        puts annotation.getElementLocalID
        puts annotation.getItemKey
        puts annotation.getUrl.toString
        annotations_index= annotations_index+1
       end
      list_index = list_index +1
    end
   
   return []
  end
  
  def  self.gatherResourcesCui(keyword) 
   result_list=[]
    
   @obsresult = Rjb::import('obs.user.OBSResult')
   obsresult = @obsresult.new(keyword)
   
   puts obsresult.getResultLines.size;
   
   list_index =0
    
    while list_index < obsresult.getResultLines.size

      resource = obsresult.getResultLines.get(list_index)
      result = {"logo"=>resource.getLineLogo().toString,
                "name"=>resource.getLineName(),
                "desc"=>resource.getLineDescription(),
                "num"=>resource.getLineNumber}
               
      
      annotations_index = 0;
      annotations=[]
       while annotations_index < resource.getLineAnnotations.size
        annotation = resource.getLineAnnotations.get(annotations_index)
        annotation={"local"=>annotation.getElementLocalID,
                    "key"=>annotation.getItemKey,
                    "url"=>annotation.getUrl.toString}
        annotations << annotation
        annotations_index= annotations_index+1
      end
      
      result["annotations"]=annotations
      result_list << result
      list_index = list_index +1
    end
   
   return result_list
  end
  
  
   def  self.gatherResources(keyword,ontology) 
   result_list=[]
    
   @obsresult = Rjb::import('obs.user.OBSResult')
   obsresult = @obsresult.new(ontology,keyword)
   
   puts obsresult.getResultLines.size;
   
   list_index =0
    
    while list_index < obsresult.getResultLines.size

      resource = obsresult.getResultLines.get(list_index)
      result = {"logo"=>resource.getLineLogo().toString,
                "name"=>resource.getLineName(),
                "desc"=>resource.getLineDescription(),
                "num"=>resource.getLineNumber}
               
      
      annotations_index = 0;
      annotations=[]
       while annotations_index < resource.getLineAnnotations.size
        annotation = resource.getLineAnnotations.get(annotations_index)
        annotation={"local"=>annotation.getElementLocalID,
                    "key"=>annotation.getItemKey,
                    }
        annotations << annotation
        annotations_index= annotations_index+1
      end
      
      result["annotations"]=annotations
      result_list << result
      list_index = list_index +1
    end
   
   return result_list
  end
  
  
  
end