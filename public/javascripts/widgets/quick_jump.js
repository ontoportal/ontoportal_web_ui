
//Installs my beautiful jquery
var scriptNode = document.createElement('SCRIPT');
    scriptNode.type = 'text/javascript';
    scriptNode.src = "http://bioportal.bioontology.org/javascripts/jquery.js";

var headNode = document.getElementsByTagName('HEAD');
if (headNode[0] != null) {
    if(typeof jQuery == 'undefined')
        headNode[0].appendChild(scriptNode);
}else{
    // if no head tag exists create it
    htmlNode = document.getElementsByTagname("HTML")
    headNode = document.createElement('HEAD')
    htmlNode[0].appendChild(headNode)
    if (typeof jQuery == 'undefined')
        headnode[0].appendChild(scriptNode)
}
    
    // install any CSS we need
    var head = document.getElementsByTagName('head')[0];
    jQuery(document.createElement('link'))
        .attr({type: 'text/css', href: 'http://stage.bioontology.org/javascripts/JqueryPlugins/autocomplete/jquery.autocomplete.css', rel: 'stylesheet', media: 'screen'}).appendTo(head);


// Begin code specific to plugin

    var searchbox;

    function jumpToValue(li){
    	if( li == null ){
    	// Im doing a search	

    	var search = confirm("Concept could not be found..\n Press OK to go to the Bioportal Search page or Cancel to try again")
    		if(search){
    		    document.location="http://stage.bioontology.org/search"
    			return
    		}
    	}

    		// if coming from an AJAX call, let's use the CityId as the value
    		if( !!li.extra ){

    			var sValue = li.extra[0];

    			document.location="http://stage.bioontology.org/visualize/"+BP_ontology_id+"/"+sValue;
    	//		jQuery.blockUI({ message: '<h1><img src="/images/tree/spinner.gif" /> Loading Concept...</h1>' }); 
    			return
    		}


    }

    function formatItem(row) {
     	return row[0] + " <span style='font-size:9px;color:blue;'>(" + row[2] + ")</span>";
    }



        document.write("Jump To:<input type=\"textbox\" id=\"BP_search_box\" size=\"30\"> <input type=\"button\" value=\"Go\" onclick=\"searchbox.findValue()\">")

        // Grab the specific scripts we need and fires it start event
        $.getScript("http://stage.bioontology.org/javascripts/JqueryPlugins/autocomplete/crossdomain_autocomplete.js",function(){

        setTimeout('jQuery("#BP_search_box").autocomplete("http://stage.bioontology.org/search/json_search/"+BP_ontology_id, { lineSeparator:"~!~",matchSubset:0,minChars:3,maxItemsToShow:20,onFindValue:jumpToValue,formatItem:formatItem });',1000);
	    searchbox =  $("#BP_search_box")[0].autocompleter;
});




