	// function to replace 'object_id' html with the response from the URL.  Basic Ajax concept
	

// Cache Implementation
var cache = new Object();
var que= new Array();
var queIndex = 0;
var thread=0;
var currentOntology;

// Invalidate and Refetch
	function refreshCache(nodeID){
		cache[nodeID]=null
		queData([nodeID],currentOntology)
	}


// Cache Getter
	function getCache(nodeID){
		if(cache[nodeID]!=null){
			return cache[nodeID]
		}else{
			return null;
		}
	}
// Cache Setter	
	function setCache(nodeID,content){
		cache[nodeID]=content
	}
	
// Starts the prefetching 	
	function queData(nodes,ontology){
		currentOntology = ontology
		// Disables Cache
		return false;
		
		que = nodes.concat(que)
		// set how many threads you want fetching data
		queIndex = 0
		thread++
		preFetchData(que[queIndex],ontology,thread);
		//preFetchData(que[1],ontology)			
		
	}

// The prefetching function	
	function preFetchData(node_id,ontology,threadNumber) {
		
			
			var responseSuccess = function(o)
			{
				var respTxt = o.responseText;
				tabData = respTxt.split("|||")
				setCache(node_id,tabData)
				queIndex++
				
				// makes sure the que isnt complete and makes sure that this thread shouldnt die
				
				if(queIndex < que.length && thread == threadNumber){				
				preFetchData(que[queIndex],ontology,threadNumber)
				}else if(queIndex >= que.length){
					que = new Array();
				}
			
			}	
			
			var responseFailure = function(o){
			
			}

			var callback =
			{
				success:responseSuccess,
				failure:responseFailure
			};
			
		
		// see's if item is already in cache, if not it makes the ajax call
		if(getCache(node_id)==null){		
			YAHOO.util.Connect.asyncRequest('GET','/'+ontology+'/'+node_id+"?callback=load",callback);		
		}else{
			queIndex++
			if(queIndex < que.length && thread == threadNumber){				
				preFetchData(que[queIndex],ontology,threadNumber)
				}else if(queIndex >= que.length){
					que = new Array();
				}
		}	
		
		}
	
	
//-------------------------------
	
		function updateArea(method,url,object_id){
	
			var responseSuccess = function(o)
			{
				var path;
				var dirs;
				var files;
				var respTxt = o.responseText;

				document.getElementById(object_id).innerHTML=respTxt
				YAHOO.wait.container.wait.hide();
				
			}

			var responseFailure = function(o){
				YAHOO.wait.container.wait.hide();
				alert('responseFailure: ' +	o.statusText);
			}

			var callback =
			{
				success:responseSuccess,
				failure:responseFailure
			};

			// Show the Panel 
			YAHOO.wait.container.wait.show();
			var cObj = YAHOO.util.Connect.asyncRequest(method,url,callback);
		}
	
	
function toggleHide(id,name_to_hide){
	toggle = true;
	element = document.getElementById(id);
	if(element.style.display==""){
		toggle = false;
	}

	if(name_to_hide !=null && name_to_hide != ""){
		elements = document.getElementsByName(name_to_hide);
		for( var x = 0; x<elements.length; x++){
			elements[x].style.display="none";
		}
	}
	
	if(toggle){
		if (element.style.display=="none"){
			element.style.display="";
		}
	}else{
			element.style.display="none";
		}
	
}


//helper function for demo only
function newProposal(string){
	document.getElementById('subject').value="Proposal For Change";
	document.getElementById('comment').value=string;
	
	selectBox = document.getElementById('margin_note_note_type');
	for(var x =0; x<selectBox.options.length;x++){
		option = selectBox.options[x]
		if(option.value!=5){
			option.disabled=true;
		}
		if(option.value==5){
			option.selected=true;
		}
	}
}

	function newNote(){
		toggleHide("commentForm","forms")	
	}

	

	
	function compare(note_id){
		oldValue = document.getElementById("oldValue").innerHTML;
		element = document.getElementById("note_value"+note_id)
		target = document.getElementById("note_text"+note_id)
	 	var d = dmp.diff_main(oldValue, element.value);
	  	dmp.diff_cleanupSemantic(d);
	  	target.innerHTML=dmp.diff_prettyHtml(d)	
	}
	
	function hide(id){
		document.getElementById(id).style.display="none"
	}
	function unhide(id){
		document.getElementById(id).style.display=""
	}
	
	
 
function buildWait(){
   YAHOO.namespace("wait.container");
	// Initialize the temporary Panel to display while waiting for external content to load
	YAHOO.wait.container.wait = new YAHOO.widget.Panel("wait",  
				{ width:"240px", 
				  fixedcenter:true, 
				  close:false, 
				  draggable:false, 
				  zindex:4,
				  modal:true,
				  visible:false
				} 
			);

	YAHOO.wait.container.wait.setHeader("Loading, please wait...");
	YAHOO.wait.container.wait.setBody('<img src="http://us.i1.yimg.com/us.yimg.com/i/us/per/gr/gp/rel_interstitial_loading.gif" />');
	YAHOO.wait.container.wait.render(document.body);
	
	
	
}

	
 
function buildSearchWait(){
   YAHOO.namespace("wait.container");
	// Initialize the temporary Panel to display while waiting for external content to load
	YAHOO.wait.container.wait = new YAHOO.widget.Panel("wait",  
				{ width:"240px", 
				  fixedcenter:true, 
				  close:false, 
				  draggable:false, 
				  zindex:4,
				  modal:true,
				  visible:false
				} 
			);

	YAHOO.wait.container.wait.setHeader("Searching, please wait...");
	YAHOO.wait.container.wait.setBody('<img src="http://us.i1.yimg.com/us.yimg.com/i/us/per/gr/gp/rel_interstitial_loading.gif" />');
	YAHOO.wait.container.wait.render(document.body);
	
	
	
}



// Selects the current clicked node.
function toggleSelected(node){

	var index=1;
	
	// can get in endless loop if you jump to a node that is free floating.
	nullCount = 0;
	while (nullCount < 20){
		if(tree.getNodeByIndex(index)!=null){
			if (tree.getNodeByIndex(index).labelStyle=='ygtvlabel-selected'){
				tree.getNodeByIndex(index).labelStyle='ygtvlabel'
				break;
			}
		}else{
			nullCount ++;
		}
	index++;
	}
	node.labelStyle="ygtvlabel-selected";	
	
}

	function buildTabs(){
	    var tabView = new YAHOO.widget.TabView('tabframe');
		
		//YAHOO.namespace("feed");
		//YAHOO.feed.feed = new YAHOO.widget.Panel("feedPanel", { context:["feed","tr","br"], width:"320px", visible:false,draggable:false,constraintoviewport:true  } ); 
		//YAHOO.feed.feed.render();
		//YAHOO.util.Event.addListener("feed", "click", YAHOO.feed.feed.show, YAHOO.feed.feed, true); 
		
		var split = new Ext.SplitBar("dragSpot", "leftbar",
	                   Ext.SplitBar.HORIZONTAL, Ext.SplitBar.LEFT);
			split.setAdapter(new Ext.SplitBar.AbsoluteLayoutAdapter("container"));
			split.minSize = 100;
			split.maxSize = 400;
			split.animate = true;
			split.on('moved', splitterMoved);
	}
	
	function splitterMoved(splitbar,newSize){
		var rightSide = Ext.get('centerContent');
		var tabFrame = Ext.get('tabframe');
		var leftSide = Ext.get('leftbar');
		
	}
	
	function resetNoteForm(uniq){		
		document.getElementById("note_subject"+uniq).value=""
		document.getElementById("note_comment"+uniq).value=""
	}


var myEditor;



function buildEditor(uniq){
	

	
	var Dom = YAHOO.util.Dom,
        Event = YAHOO.util.Event;
	
	myEditor = new YAHOO.widget.SimpleEditor('note_comment'+uniq, {
    height: '300px',
    width: '522px',
    dompath: false //Turns on the bar at the bottom
});
myEditor.render();
}

function saveNote(){
	myEditor.saveHTML();
	myEditor.destroy();
}

function destroyEditor(){
		myEditor.clearEditorDoc();
		myEditor.destroy();
		
}


function update_tab(ontology,concept){
	
	var responseSuccess = function(o)
			{
			
				
			}

			var responseFailure = function(o){
				
			}

			var callback =
			{
				success:responseSuccess,
				failure:responseFailure
			};


			// Show the Panel 
			var cObj = YAHOO.util.Connect.asyncRequest("GET","/tab/update/"+ontology+"/"+concept,callback);
	
	
	
}


function remove_tab(link,ontology,redirect){

	
			var responseSuccess = function(o)
			{
				if(redirect){
					window.location="/ontologies"
				}else{
					tab= document.getElementById("tab"+ontology)		
					parent = tab.parentNode	
					parent.removeChild(tab)
		
				}
				
			}

			var responseFailure = function(o){
				
			}

			var callback =
			{
				success:responseSuccess,
				failure:responseFailure
			};


			// Show the Panel 
			var cObj = YAHOO.util.Connect.asyncRequest("GET","/tab/remove/"+ontology,callback);
	
	


}
