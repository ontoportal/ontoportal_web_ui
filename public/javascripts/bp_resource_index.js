var testVar = currentOntologyIds().join(",");

jQuery(document).ready(function(){

  // Hide/Show resources
  jQuery(".resource_link").live("click", function(event){
    event.preventDefault();
    switchResources(this);
  });

  // Make chosen work via ajax
  jQuery("#resource_index_terms").ajaxChosen({
      minLength: 3,
      queryLimit: 10,
      delay: 500,
      chosenOptions: {},
      searchingText: "Searching for term...",
      noresultsText: "No results.",
      initialQuery: false
    }, function (options, response, event) {
      jQuery.getJSON("/search/json", {query: options.term, ontology_ids: currentOntologyIds().join(",")}, function (data) {
        var terms = {};
        jQuery.each(data.results, function (index, result) {
            terms[result.ontologyId + "/" + result.conceptIdShort] = "&nbsp;<span title='" + result.ontologyDisplayLabel + "'>" + result.preferredName + "<span class='search_dropdown_ont'>(" + result.ontologyDisplayLabel + ")</span></span>";
        });
        response(terms);
    });
  });

  jQuery("#resource_index_button").click(function(){
    jQuery("#results_error").html("");
    jQuery("#resource_index_spinner").show();
    var params = {
      "ontologyids": currentOntologyIds(),
      "conceptids": currentConceptIds()
    };

    jQuery.ajax({
      type: 'POST',
      url: '/resource_index',
      data: params,
      dataType: 'html',
      success: function(data) {
        jQuery("#results").html(data);
        jQuery("#results_container").show();
        jQuery("#resource_index_spinner").hide();
      },
      error: function() {
        jQuery("#resource_index_spinner").hide();
        jQuery("#results_error").html("Problem retrieving search results, please try again");
      }
    })
  })

  jQuery(".show_element_details").live("click", function(e){
    e.preventDefault();

    var el = jQuery(this);
    var cleanElementId = el.attr("data-clean_element_id");
    var el_text = jQuery("#"+cleanElementId+"_text");
    el_text.toggleClass("not_visible");
    if (el_text.attr("highlighted") !== "true") {
      var element = new Element(el.attr("data-element_id"), cleanElementId, currentConceptIds(), el.attr("data-resource_id"));
      jQuery("#"+element.cleanId+"_link").append("<span class='highlighting'>highlighting...</span>");
      element.getAnnotationPositions();
      el_text.attr("highlighted", "true");
    }
  });
});

function Element(id, cleanId, conceptIds, resource) {
  this.positions;
  this.id = id;
  this.cleanId = cleanId;
  this.jdomId = "#"+cleanId+"_text";
  this.conceptIds = conceptIds;
  this.resource = resource;


  this.getAnnotationPositions = function() {
    var element = this;
    jQuery.ajax({
      url: "/resource_index/element_annotations",
      data: {
        elementid: this.id,
        conceptids: this.conceptIds.join(","),
        resourceid: this.resource
      },
      dataType: "json",
      success: function(data) {
        element.positions = data;
        element.highlight();
      }
    });
  }

  this.highlight = function() {
    var element = this;
    jQuery.each(this.positions,
      function(contextName, positions){
        var context = jQuery(element.jdomId+" p[data-context_name="+contextName+"]");
        if (context.length !== 0) {
          highlighter = new PositionHighlighter();
          // Replace the current text with highlighted version
          context.html(highlighter.highlightUsingPosition(context.html(), positions));
        }
      }
    );
    jQuery("#"+this.cleanId+"_link").children(".highlighting").remove();
  }

}

function switchResources(res) {
  var res = jQuery(res);
  var resId = res.attr("data-resource_id");
  // Hide the active resource if you click on it while it's active. Otherwise, switch.
  if (res.hasClass("active_resource")) {
    res.removeClass("active_resource");
    jQuery("#resource_info_"+resId).addClass("not_visible");
  } else {
    jQuery("#resource_info .resource_info").addClass("not_visible");
    jQuery("#resource_info_"+resId).removeClass("not_visible");
    jQuery("#resource_info .resource_link").removeClass("active_resource");
    res.addClass("active_resource");
    jQuery(window).scrollTop(document.getElementById("resource_header_"+resId).offsetTop);
  }
}

function PositionHighlighter() {
  this.offsetPositions = [];
  this.textToHighlight = "";

  this.highlightUsingPosition = function(text, positions) {
    // This is stupid, but annotator/resource index output starts counting text at one
    var start = 1;
    var end = text.length;
    var positionsLength = positions.length;
    var highlightType, startPosition, endPosition;

    // We do this to decode HTML entities
    this.textToHighlight = jQuery("<div/>").html(text).text();

    // Starting offsets should be zero
    for (var i = start; i <= end; i++) {
      this.offsetPositions[i] = 0;
    }

    for (var j = 0; j < positionsLength; j++) {
      highlightType = positions[j]['type'];
      startPosition = positions[j]['from'];
      endPosition = positions[j]['to'];

      // Add the highlight opener
      this.addText("<span class='"+highlightType+"'>", startPosition, -1);
      // Add the highlight closer
      this.addText("</span>", endPosition, 0);
    }

    return this.textToHighlight;
  }

  this.updatePositions = function(start, added_count) {
    var offset_length = this.offsetPositions.length;
    for (var i = start; i <= offset_length; i++) {
      this.offsetPositions[i] += added_count;
    }
  }

  this.addText = function(textToAdd, position, offset) {
    this.textToHighlight = [this.textToHighlight.slice(0, this.getActualPosition(position) + offset), textToAdd, this.textToHighlight.slice(this.getActualPosition(position) + offset)].join('');
    this.updatePositions(position, textToAdd.length);
  }

  this.getActualPosition = function(position) {
    return position + this.offsetPositions[position];
  }
}

function currentOntologyIds() {
  var selectedOntIds = jQuery("#ontology_ontologyId").val();
  return selectedOntIds == null || selectedOntIds === "" ? ri_ontology_ids : selectedOntIds;
}

function currentConceptIds() {
  return jQuery("#resource_index_terms").val();
}
