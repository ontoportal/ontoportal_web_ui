module OntologyMetricsHelper
  
  def class_list_info(ontology, metric, message, title)
    if ontology.metrics.send("#{metric}").nil?
      return
    end
    
    # Check to see if all properties are missing (author/doc only)
    if defined? ontology.metrics.send(:"#{metric}Missing") && ontology.metrics.send(:"#{metric}Missing") == true
      return "All properties are missing"
    end
    
    markup = ""
    
    # Below we will use the 'send' method to call setters/getters based on the metric name we're looking for
    if ontology.metrics.send(:"#{metric}Percentage") == 1
      markup << "All classes #{message}"
    elsif ontology.metrics.send(:"#{metric}LimitPassed") == true && ontology.metrics.numberOfClasses > OntologyMetricsWrapper::CLASS_LIST_LIMIT
      all_missing = true
      markup << "We estimate that all classes #{message}"
    else
      percentage = "%0.2f" % (ontology.metrics.send(:"#{metric}Percentage") * 100)
      class_list_length = ontology.metrics.send(:"#{metric}").length
      markup << "#{class_list_length} / #{ontology.metrics.numberOfClasses} (#{percentage}%) of classes #{message}"
    end
    
    markup << ' (<a class="thickbox" href="#TB_inline?height=600&width=800&inlineId=%metric%">details</a>)'.gsub("%title%", title).gsub("%metric%", metric)
    markup << '<div id="%metric%" style="display: none;"><div class="metrics">'.gsub("%metric%", metric)
    
    if all_missing
      markup << "<h2>Estimated metrics</h2>
                 <p>Currently, BioPortal checks to see if an ontology is using a default property
                 or one chosen by the ontology provider to indicate authorship or definitions for classes.
                 However, many ontologies do not implement these properties. In order to prevent
                 listing all classes for ontologies not implementing these properties, we only list the first 200
                 and make the estimation that all classes in the ontology lack them. Future
                 implementations will track the total number of classes that are missing these properties
                 and provide more accurate statistics about the overall ontology.
                 <a href=\"http://www.bioontology.org/wiki/index.php/Ontology_Metrics\">More information</a></p>"
    end
    
    markup << "<h2>#{title} list</h2><p>"
    ontology.metrics.send(:"#{metric}").each do | class_name, count | 
      markup << "#{class_name}" 
      if count
        markup << " (#{count} subclasses)"
      end
      markup << "<br />"
    end 
    markup << "</p></div></div>"
    
    return markup    
  end
  
end