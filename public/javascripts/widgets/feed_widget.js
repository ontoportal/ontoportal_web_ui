
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
    
  

document.write("<div id='bp_feed_container'><ul id='bp_feed'></ul></div>")

$(document).ready(function(){
    
    $.getJSON("http://stage.bioontology.org/syndication/rss?ontologies="+BP_ontology_id+"&limit=5&callback=?",function(data){
        
        for(item in data){
            jQuery("#bp_feed").append("<li><a href='"+data[item].link+"'>"+data[item].title+"</a> "+data[item].date+"<br/>"+data[item].description+"<br/></li>")
        }
        
    })
    
})




