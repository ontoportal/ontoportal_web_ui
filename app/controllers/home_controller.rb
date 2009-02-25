class HomeController < ApplicationController
  
  layout 'ontology'
  
  def index  
    @ontologies = DataAccess.getOntologyList() # -- Gets list of ontologies
    @categories = DataAccess.getCategories()
    @last_notes= MarginNote.find(:all,:order=>'created_at desc',:limit=>5)    
    @last_mappings = Mapping.find(:all,:order=>'created_at desc',:limit=>5)
    
    @sorted_ontologies={}
    
    @sorted_ontologies["0"]=[]
    
    for cat in @categories.keys
      @sorted_ontologies[cat]=[]
    end
    
    for ontology in @ontologies
      for cat in ontology.categories
        @sorted_ontologies[cat]<<ontology
      end
      
      if ontology.categories.empty?
        @sorted_ontologies["0"]<<ontology
      end
      
    end
    
    @category_tree = @categories.clone
    puts @category_tree.inspect
    
    
    for value in @category_tree.values
      value[:children]=[]
    end
    
    for category in @categories.values
      if !category[:parentId].nil? && !category[:parentId].eql?("")
        puts "Parent: #{category.inspect}"
        @category_tree[category[:parentId]][:children]<<category
      end
    end
    
    puts "Category check #{@category_tree["2811"][:name]} #{@category_tree["2811"][:children].inspect}"
    puts "Size is #{@category_tree.values.size}"
    
    for value in @categories.values
      if !value[:parentId].nil? && !value[:parentId].eql?("")
        puts "deleting #{value.inspect}"
        @category_tree.delete(value[:id])
      end
    end

    @sorted_categories = @category_tree.values.sort{|a,b| a[:name] <=> b[:name]}
  	
    for cat in @sorted_categories
      puts "#{cat[:name]} --> #{cat[:children].inspect}"
    end
    
    
     if !params[:ver].nil?
       render :action=> "index#{params[:ver]}"
     end     
     
  end

  def release
    
  end


  def feedback
    
  end
  def send_feedback    
    Notifier.deliver_feedback(params[:name],params[:email],params[:comment])   
    flash[:notice]="Feedback has been sent"
    redirect_to_home
  end



end
