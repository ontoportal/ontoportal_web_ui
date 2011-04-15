// History and navigation management
(function(window,undefined) {
  // Establish Variables
  var History = window.History;
  History.debug.enable === true;
  
  // Bind to State Change
  History.Adapter.bind(window, 'statechange', function() {
    var hashParams = null;
    var queryStringParams = null;
    var params = {};
    var state = History.getState();
    
    if (typeof state.data.p !== 'undefined') {
      if (state.data.p == "tree_view") {
        displayTree(state.data);
      }
      
      showOntologyContent(state.data.p);
    } else if (typeof state.url !== 'undefined') {
      
      if (window.location.hash != "") {
        hashParams = window.location.hash.split('?').pop().split('&');
        
        jQuery(hashParams).each(function(index, value){
          var paramName = value.split("=")[0];
          var paramValue = value.split("=")[1];
          params[paramName] = paramValue;
        });
      } else {
        queryStringParams = window.location.search.substring(1).split("&");
        
        jQuery(queryStringParams).each(function(index, value){
          var paramName = value.split("=")[0];
          var paramValue = value.split("=")[1];
          params[paramName] = paramValue;
        });
      }
      
      if (typeof params["p"] !== 'undefined' && content_section != params["p"]) {
        showOntologyContent(params["p"]);
        document.title = jQuery.bioportal.ont_pages[params["p"]].page_name + " | " + org_site;
        
        // We need to get everything using AJAX
        content_section = null;
      } else {
        showOntologyContent(content_section);
        document.title = jQuery.bioportal.ont_pages[content_section].page_name + " | " + org_site;
      }
    }
  });
})(window);

// Handles display of the tree depending on parameters
function displayTree(data) {
  var new_concept_id = data.conceptid;
  
  // Check to see if we're actually loading a new concept or just displaying the one we already loaded previously
  if (typeof new_concept_id === 'undefined' || new_concept_id == concept_id) {
    if (concept_id !== "") {
        History.replaceState({p:"tree_view", conceptid:concept_id}, jQuery.bioportal.ont_pages["tree_view"].page_name + " | " + org_site, "?p=tree_view" + "&conceptid=" + concept_id);
    }
    
    jQuery.unblockUI();
    
    return;
  } else {
    var new_concept_param = (typeof new_concept_id === 'undefined') ? "" : "&conceptid=" + new_concept_id;
    
    if (typeof new_concept_id !== 'undefined') {
      // Retrieve new concept and display tree
      jQuery.bioportal.ont_pages["tree_view"] = new jQuery.bioportal.OntologyPage("tree_view", "/ontologies/" + ontology_id + "?p=tree_view" + new_concept_param, "Problem retrieving terms", ontology_name + " - Terms", "Terms");
      
      if (typeof data.suid !== 'undefined' && data.suid === "jump_to") {
        jQuery.blockUI({ message: '<h1><img src="/images/tree/spinner.gif" /> Loading Term...</h1>', showOverlay: false }); 
        // Are we jumping into the ontology? If so, get the whole tree
        jQuery.bioportal.ont_pages["tree_view"].retrieve_and_publish();
      } else {
        jQuery.blockUI({ message: '<h1><img src="/images/tree/spinner.gif" /> Loading Term...</h1>', showOverlay: false }); 
        if (document.getElementById(new_concept_id) !== null) {
          // We have a visible node that's been clicked, get the details for that node
          nodeClicked(new_concept_id);
        } else {
          // Get a new copy of the three because our concept isn't visible
          // This could be due to using the forward/back button
          jQuery.bioportal.ont_pages["tree_view"].retrieve_and_publish();
        }
      }
    } else {
      // Retrieve new concept and display tree
      jQuery.bioportal.ont_pages["tree_view"] = new jQuery.bioportal.OntologyPage("tree_view", "/ontologies/" + ontology_id + "?p=tree_view", "Problem retrieving terms", ontology_name + " - Terms", "Terms");
      jQuery.bioportal.ont_pages["tree_view"].retrieve_and_publish();
    }

    if (typeof new_concept_id !== 'undefined') {
      concept_id = new_concept_id;
    }
  }
}

function showOntologyContent(content_section) {
  jQuery(".ontology_viewer_content").addClass("hidden");
  jQuery("#ont_" + content_section + "_content").removeClass("hidden");
  jQuery("#nav_text").html(jQuery.bioportal.ont_pages[content_section].nav_text);
}

// Prevent the default behavior of clicking the ontology page links
// Instead, fire some history events
var nav_ont = function(link) {
  var page = jQuery(link).attr("data-bp_ont_page");
  History.pushState({p:page}, jQuery.bioportal.ont_pages[page].page_name + " | " + org_site, "?p=" + page);
}


jQuery(document).ready(function() {
  // Set appropriate title
  var title = (content_section == null) ? ontology_name + " | " + org_site
    : jQuery.bioportal.ont_pages[content_section].page_name + " | " + org_site;
  document.title = title;
  
  // Wire up navigation buttons
  jQuery('#ont_nav').menu({ 
    content: jQuery('#ont_nav').next().html(),
    afterItemChosen: nav_ont
  });
  jQuery('#ont_admin').menu({ 
    content: jQuery('#ont_admin').next().html(),
    afterItemChosen: menu_nav
  });
  
  // Retrieve AJAX content if not already displayed
  if (content_section !== "tree_view" && tree_view_disabled != true) {
    jQuery.bioportal.ont_pages["tree_view"].retrieve_and_publish();
    
    // if (typeof concept_id !== 'undefined') {
    //   jQuery.cache.tree_view[concept_id] = jQuery.bioportal.ont_pages["tree_view"].html; 
    // } else {
    //   jQuery.cache.tree_view["root"] = jQuery.bioportal.ont_pages["tree_view"].html;
    // }
  }
    
  if (content_section !== "summary") {
    jQuery.bioportal.ont_pages["summary"].retrieve_and_publish();
  }

  if (content_section !== "mappings") {
    jQuery.bioportal.ont_pages["mappings"].retrieve_and_publish();
  }

  if (content_section !== "notes") {
    jQuery.bioportal.ont_pages["notes"].retrieve_and_publish();
  }
  
  if (content_section !== "widgets" && tree_view_disabled != true) {
    jQuery.bioportal.ont_pages["widgets"].retrieve_and_publish();
  }
  
  // Set the proper name in the nav menu
  if (content_section !== null) {
    jQuery("#nav_text").html(jQuery.bioportal.ont_pages[content_section].nav_text);
  }
});

// Parent class to ontology pages
// We're using a monkeypatched function to setup prototypging, see bioportal.js
jQuery.bioportal.OntologyPage = function(id, location_path, error_string, page_name, nav_text, init){
  this.id = id;
  this.location_path = location_path;
  this.error_string = error_string;
  this.page_name = page_name;
  this.error_string = error_string;
  this.nav_text = nav_text;
  this.errored = false;
  this.html;
  
  this.retrieve = function(){
    jQuery.ajax({
      dataType: "html",
      url: this.location_path,
      context: this,
      success: function(data){
        this.html = data;
      },
      error: function(){
        this.errored = true;
      }
    });
  };
  
  this.retrieve_and_publish = function(){
    jQuery.ajax({
      dataType: "html",
      url: this.location_path,
      context: this,
      success: function(data){
        this.html = data;
        jQuery("#ont_" + this.id + "_content").html("");
        jQuery("#ont_" + this.id + "_content").html(this.html);
        jQuery.unblockUI(); 
      },
      error: function(){
        this.errored = true;
        jQuery("#ont_" + this.id + "_content").html("");
        jQuery("#ont_" + this.id + "_content").html("<div style='padding: 1em;'>" + this.error_string + "</div>");
        jQuery.unblockUI(); 
      }
    });
  };

  this.publish = function(){
    if (this.errored === false) {
      jQuery("#ont_" + this.id + "_content").html(this.html);
      jQuery.unblockUI(); 
    } else {
      jQuery("#ont_" + this.id + "_content").html("<div style='padding: 1em;'>" + this.error_string + "</div>");
      jQuery.unblockUI(); 
    }
  };
}

// Setup AJAX page objects
jQuery.bioportal.ont_pages = [];

jQuery.bioportal.ont_pages["tree_view"] = new jQuery.bioportal.OntologyPage("tree_view", "/ontologies/" + ontology_id + "?p=tree_view" + concept_param, "Problem retrieving terms", ontology_name + " - Terms", "Terms");
jQuery.bioportal.ont_pages["summary"] = new jQuery.bioportal.OntologyPage("summary", "/ontologies/" + ontology_id + "?p=summary", "Problem retrieving summary", ontology_name + " - Summary", "Summary");
jQuery.bioportal.ont_pages["mappings"] = new jQuery.bioportal.OntologyPage("mappings", "/ontologies/" + ontology_id + "?p=mappings", "Problem retrieving mappings", ontology_name + " - Mappings", "Mappings");
jQuery.bioportal.ont_pages["notes"] = new jQuery.bioportal.OntologyPage("notes", "/ontologies/" + ontology_id + "?p=notes", "Problem retrieving notes", ontology_name + " - Notes", "Notes");
jQuery.bioportal.ont_pages["widgets"] = new jQuery.bioportal.OntologyPage("widgets", "/ontologies/" + ontology_id + "?p=widgets", "Problem retrieving widgets", ontology_name + " - Widgets", "Widgets");
