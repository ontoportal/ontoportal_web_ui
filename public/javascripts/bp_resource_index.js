// History and navigation management
(function(window,undefined) {
  // Establish Variables
  var History = window.History;
  History.debug.enable = true;

  // Bind to State Change
  History.Adapter.bind(window, 'statechange', function() {
    var state = History.getState();
    if (typeof state.data.route !== "undefined") {
      router.route(state.data.route, state.data);
    } else {
      router.route("index");
    }
  });
})(window);

var BP_urlParams = {};
(function () {
    var match,
        pl     = /\+/g,  // Regex for replacing addition symbol with a space
        search = /([^&=]+)=?([^&]*)/g,
        decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
        query  = window.location.search.substring(1);

    while (match = search.exec(query))
       BP_urlParams[decode(match[1])] = decode(match[2]);
})();

function pageInit() {
  var state = History.getState();
  var params = {}, paramLocations = ["root", "resources", "resourceId"], route, queryString;
  route = state.hash.split("?");
  queryString = (typeof route[1] !== "undefined") ? "" : route[1];
  route = route[0].split("/").slice(1);
  for (var i = 0; i < route.length; i++) {
    params[paramLocations[i]] = route[i];
  }
  jQuery.extend(params, BP_urlParams);
  params["conceptids"] = (typeof params["conceptids"] !== "undefined") ? params["conceptids"].split(",") : undefined;
  BP_urlParams = params;

  if (typeof params["resourceId"] !== "undefined") {
    router.route("resource", params);
  } else if (typeof params["resources"] !== "undefined") {
    router.route("resources", params);
  }
}

function pushDisplayResource(url, params) {
  params["route"] = "resource";
  History.pushState(params, document.title, url);
}

function pushDisplayResources(url, params) {
  params["route"] = "resources";
  History.pushState(params, document.title, url);
}

function pushIndex() {
  History.pushState(null, document.title, "/resource_index");
}

function replaceIndex() {
  History.replaceState(null, document.title, "/resource_index");
}

function Router() {
  this.route = function(route, params) {
    switch(route) {
      case "index":
        this.index();
        break;
      case "resources":
        this.resources(params);
        break;
      case "resource":
        this.resource(params);
        break;
    }
  }

  this.index = function() {
    jQuery("#results").html("");
    jQuery("#results_error").html("");
    jQuery("#resource_index_terms_chzn .search-choice-close").click();
  }

  this.resources = function(params) {
    if (typeof params["conceptids"] === "undefined") {
      replaceIndex();
    }

    displayResources(params["conceptids"]);
  }

  this.resource = function(params) {
    if (typeof params["conceptids"] === "undefined" || typeof params["resourceId"] === "undefined") {
      replaceIndex();
    }

    displayResource(params);
  }
}
router = new Router();

function displayResource(params) {
  var resource = params["resourceId"];
  var resourceName = resources[resource.toLowerCase()].resourceName;

  // Only retreive term information if this is an initial load
  if (jQuery("#resource_index_terms").val() !== null) {
    showResourceResults(resource, resourceName);
    return;
  }

  displayTerms(params["conceptids"], function() {
    showResourceResults(resource, resourceName);
  });
}

function displayResources(concepts) {
  // Only retreive term information if this is an initial load
  if (jQuery("#resource_index_terms").val() !== null) {
    showAllResources();
    return;
  }

  displayTerms(concepts);
}

function displayTerms(concepts, completedCallback) {
  var concept, conceptOpt, ontologyId, conceptId, ontologyName, conceptRetreivedCount;

  conceptRetreivedCount = 0;
  jQuery("#resource_index_terms").html("");
  for (var i = 0; i < concepts.length; i++) {
    concept = concepts[i];
    ontologyId = concept.split("/")[0];
    conceptId = concept.split("/")[1];
    jQuery.getJSON("/ajax/json_term?ontologyid="+ontologyId+"&conceptid="+conceptId, function(data){
      ontologyName = ont_names[ontologyId];
      jQuery("#resource_index_terms").append(jQuery("<option/>").val(concept).html(" "+data.label+" <span class='search_dropdown_ont'>("+ontologyName+")</span>"));
      conceptRetreivedCount += 1;
      if (conceptRetreivedCount == concepts.length) {
        for (var i = 0; i < concepts.length; i++) {
          conceptOpt = concepts[i];
          jQuery("#resource_index_terms option[value='"+conceptOpt+"']").attr("selected", true);
        }
        updateChosen();
        getSearchResults(completedCallback);
      }
    });
  }
}

function updateChosen() {
  jQuery("#resource_index_terms").trigger("liszt:updated");
  jQuery("#resource_index_terms").trigger("change");
}

jQuery(document).ready(function(){

  // Hide/Show resources
  jQuery(".resource_link").live("click", function(event){
    event.preventDefault();
    switchResources(this);
  });

  // Spinner for pagination
  jQuery(".pagination a").live("click", function(){
    jQuery(this).parents("div.pagination").append('&nbsp;&nbsp; <span style="font-size: small; font-weight: normal;">loading</span> <img style="vertil-align: text-bottom;" src="/images/spinners/spinner_000000_16px.gif">');
  })

  // Make chosen work via ajax
  jQuery("#resource_index_terms").ajaxChosen({
      minLength: 3,
      queryLimit: 10,
      delay: 500,
      chosenOptions: {},
      searchingText: "Searching for term ",
      noresultsText: "Term not found",
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

  // Get search results
  jQuery("#resource_index_button").click(function(){
    var concepts = jQuery("#resource_index_terms").val();
    var url = "/resource_index/resources?conceptids="+concepts.join(",");
    pushDisplayResources(url, {conceptids: concepts});
    getSearchResults();
  });

  // Show/Hide results with zero matches
  jQuery("#show_hide_no_results").live("click", function(){
    jQuery("#resource_table .zero_results").toggleClass("not_visible").effect("highlight", { color: "yellow" }, 500);
    jQuery("#show_hide_no_results .show_hide_text").toggleClass("not_visible");
  });

  jQuery(".show_element_details").live("click", function(e){
    e.preventDefault();

    var el = jQuery(this);
    var cleanElementId = el.attr("data-clean_element_id");
    var el_text = jQuery("#"+cleanElementId+"_text");
    el_text.toggleClass("not_visible");
    if (el_text.attr("highlighted") !== "true") {
      var element = new Element(el.attr("data-element_id"), cleanElementId, currentConceptIds(), el.attr("data-resource_id"));
      jQuery("#"+element.cleanId+"_text .ri_legend_container").append("<span id='"+element.cleanId+"_ani'class='highlighting'>highlighting... <img style='vertical-align: text-bottom;' src='/images/spinners/spinner_000000_16px.gif'></span>");
      element.highlightAnnotationPositions();
      el_text.attr("highlighted", "true");
    }
  });
});

function getSearchResults(success) {
  jQuery("#results_error").html("");
  jQuery("#resource_index_spinner").show();
  jQuery("#results.contains_search_results").hide();
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
      jQuery("#results").addClass("contains_search_results");
      jQuery("#results.contains_search_results").show();
      jQuery("#results_container").show();
      jQuery("#resource_index_spinner").hide();
      if (success && typeof success === "function") {
        success();
      }
      // jQuery("#resource_table table").dataTable({
      //   "bPaginate": false,
      //   "bFilter": false
      // });
    },
    error: function() {
      jQuery("#resource_index_spinner").hide();
      jQuery("#results_error").html("Problem retrieving search results, please try again");
    }
  })
}

jQuery("a.results_link").live("click", function(event){
  var resource = jQuery(this).data("resource_id");
  var resourceName = jQuery(this).data("resource_name");
  var concepts = jQuery("#resource_index_terms").val();
  var url = "/resource_index/resources/"+resource+"?conceptids="+concepts.join(",");
  pushDisplayResource(url, {conceptids: concepts, resourceId: resource});
});

jQuery("a#show_all_resources").live("click", function(){
  var concepts = jQuery("#resource_index_terms").val();
  var url = "/resource_index/resources?conceptids="+concepts.join(",");
  pushDisplayResources(url, {conceptids: concepts});
});

function showResourceResults(resource, resourceName) {
  jQuery(".resource_info").addClass("not_visible");
  jQuery("#resource_table").addClass("not_visible");
  jQuery("#resource_info_"+resource).removeClass("not_visible");
  jQuery("#resource_title").html(resourceName);
  jQuery(".resource_title").removeClass("not_visible");
  jQuery("#resource_title").removeClass("not_visible");
}

function showAllResources() {
  jQuery(".resource_info").addClass("not_visible");
  jQuery(".resource_title").addClass("not_visible");
  jQuery("#resource_title").addClass("not_visible");
  jQuery("#resource_table").removeClass("not_visible");
}

function Element(id, cleanId, conceptIds, resource) {
  this.positions;
  this.id = id;
  this.cleanId = cleanId;
  this.jdomId = "#"+cleanId+"_text";
  this.conceptIds = conceptIds;
  this.resource = resource;
  this.loadAni = null;

  this.highlightAnnotationPositions = function() {
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
    jQuery("#"+this.cleanId+"_text").find(".highlighting").remove();
    if (this.loadAni !== null) {
      clearInterval(this.loadAni);
    }
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

function generateParameters() {
  var params = [];
  var new_params = jQuery.extend(true, {}, bp_last_params);
  delete new_params["apikey"]
  delete new_params["format"]
  jQuery.each(new_params, function(k, v){
    if (v != null && v !== "") {
      params.push(k + "=" + v);
    }
  });
  jQuery("#resource_index_parameters").html(params.join("&"));
}

// Enable sorting of numbers with commas in datatable
jQuery.fn.dataTableExt.aTypes.unshift(
    function ( sData )
    {
        var deformatted = sData.replace(/[^\d\-\.\/a-zA-Z]/g,'');
        if ( $.isNumeric( deformatted ) ) {
            return 'formatted-num';
        }
        return null;
    }
);
