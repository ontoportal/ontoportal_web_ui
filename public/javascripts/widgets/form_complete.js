
    var searchbox;

    function jumpToValue(li){
       // alert(li.extra)
        
    	if( li == null ){
    	// Im doing a search	

    	var search = confirm("Concept could not be found..\n Press OK to go to the Bioportal Search page or Cancel to try again")
    		if(search){
    		    document.location="http://stage.bioontology.org/search"
    			return
    		}
    	}

    		if( !!li.extra ){

    			var sValue = li.extra[0];
              //  alert("http://stage.bioontology.org/virtual/"+BP_ontology_id+"/"+sValue)
    			document.location="http://stage.bioontology.org/virtual/"+BP_ontology_id+"/"+sValue;
    	//		jQuery.blockUI({ message: '<h1><img src="/images/tree/spinner.gif" /> Loading Concept...</h1>' }); 
    			return
    		}


    }

    function formatItem(row) {
     	return row[0] + " <span style='font-size:9px;color:blue;'>(" + row[2] + ")</span>";
    }




        
    function setup_functions(){
        jQuery("#BP_search_box").autocomplete("http://stage.bioontology.org/search/json_search/"+BP_ontology_id, { lineSeparator:"~!~",matchSubset:0,minChars:3,maxItemsToShow:20,onFindValue:jumpToValue,formatItem:formatItem });
        searchbox =  jQuery("#BP_search_box")[0].autocompleter;	    	    	    
    }
