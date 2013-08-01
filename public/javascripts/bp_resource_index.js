// History and navigation management
(function (window, undefined) {
  // Establish Variables
  var History = window.History;
  History.debug.enable = true;

  // Bind to State Change
  History.Adapter.bind(window, 'statechange', function () {
    var state = History.getState();
    if (typeof state.data.route !== "undefined") {
      router.route(state.data.route, state.data);
    } else {
      router.route("index");
    }
  });
}(window));

var uri_split_chars = "\t::\t";
var uri_split = function(combinedURIs) {
  return combinedURIs.split(uri_split_chars);
};
var uri_combine = function(ont_uri, cls_uri) {
  return ont_uri + uri_split_chars + cls_uri;
};


var bpResourceIndexEmbedded = false;
jQuery(document).ready(function () {
  bpResourceIndexEmbedded = (jQuery("#resource_table").parents("div.resource_index_embed").length > 0);
  // Hide/Show resources
  jQuery(".resource_link").live("click", function (event) {
    event.preventDefault();
    switchResources(this);
  });

  // Spinner for pagination
  jQuery(".pagination a").live("click", function () {
    jQuery(this).parents("div.pagination").append('&nbsp;&nbsp; <span style="font-size: small; font-weight: normal;">loading</span> <img style="vertil-align: text-bottom;" src="/images/spinners/spinner_000000_16px.gif">');
  });

  // Make chosen work via ajax
  if (jQuery("#resource_index_terms").length > 0) {
    jQuery("#resource_index_terms").ajaxChosen({
      minLength    : 3,
      queryLimit   : 10,
      delay        : 500,
      chosenOptions: {},
      searchingText: "Searching for term ",
      noresultsText: "Term not found",
      initialQuery : false
    }, function (options, response, event) {
      // jQuery("#resource_index_terms_chzn .chzn-results li.active-result").remove();

      //var search_url = "/resource_index/search";
      var search_url = jQuery(document).data().bp.config.rest_url+"search";
      var search_params = {};
      search_params['apikey'] = jQuery(document).data().bp.config.apikey;
      search_params['format'] = "jsonp";
      search_params['q'] = options.term;
      // TODO: ENABLE ADDITIONAL PARAMETERS WHEN THE SEARCH API SUPPORTS THEM.
      //search_params['ontologies'] = currentOntologyIds().join(',');
      //search_params['includeProperties'] = includeProps;
      //search_params['includeViews'] = includeViews;
      //search_params['requireDefinitions'] = includeOnlyDefinitions;
      //search_params['exactMatch'] = exactMatch;
      //search_params['categories'] = categories;
      jQuery.ajax({
        url: search_url,
        data: search_params,
        dataType: "jsonp",
        success: function(data){
          jQuery("#search_spinner").hide();
          jQuery("#search_results").show();
          var terms = {}, termHTML = "";
          // TODO: Remove this variable when search API supports ontologies parameter.
          var ontologies = currentOntologyIds().join(',');
          jQuery.each(data.collection, function (index, cls) {
            var ont_uri = cls.links.ontology;
            // TODO: Remove this condition when search API supports ontologies parameter.
            if (ontologies.match(ont_uri).length > 0){
              var cls_uri = cls['@id'];
              var ont_acronym = cls.links.ontology.split('/').slice(-1)[0];
              termHTML = "" +
                "<span class='search_ontology' title='" + ont_uri + "'>" +
                  "<span class='search_class' title='" + cls_uri + "'>" +
                    cls.prefLabel +
                    "<span class='search_ontology_acronym'>(" + ont_acronym + ")</span>" +
                "</span>";
              // Create a combination of ont_uri and cls_uri that can be split when retrieved.
              // This will be the option value in the selected drop-down list.
              var combined_uri = uri_combine(ont_uri, cls_uri);
              terms[combined_uri] = termHTML;
            }
          });
          response(terms);  // Chosen plugin creates select list.
        },
        error: function(){
          jQuery("#search_spinner").hide();
          jQuery("#search_results").hide();
          jQuery("#search_messages").html("<span style='color: red'>Problem searching, please try again");
        }
      });
    });
  }

  // If all terms are removed from the search, put the UI in base state
  jQuery("a.search-choice-close").live("click", function () {
    if (chosenSearchTermsToClassesArg() === null) {
      pushIndex();
      var input = document.activeElement
      jQuery("#resource_index_terms_chzn").trigger("mousedown");
      input.blur();
      jQuery("#resource_index_terms_chzn input").data("prevVal", "");
      jQuery("#resource_index_terms_chzn .chzn-results li").remove();
    }
  });

  // Get search results
  if (jQuery("#resource_index_button").length > 0) {
    jQuery("#resource_index_button").click(function () {
      var url = "/resource_index/resources?" + chosenSearchTermsToClassesArg();
      pushDisplayResources(url, {classes: chosenSearchTerms()});
      getSearchResults();
    });
  }

  // Show/Hide results with zero matches
  jQuery("#show_hide_no_results").live("click", function () {
    jQuery("#resource_table .zero_results").toggleClass("not_visible").effect("highlight", { color: "yellow" }, 500);
    jQuery("#show_hide_no_results .show_hide_text").toggleClass("not_visible");
  });

  jQuery(".show_element_details").live("click", function (e) {
    e.preventDefault();
    var el = jQuery(this);
    var cleanElementId = el.attr("data-clean_element_id");
    var el_text = jQuery("#" + cleanElementId + "_text");
    el_text.toggleClass("not_visible");
    if (el_text.attr("highlighted") !== "true") {
      var element = new Element(el.attr("data-element_id"), cleanElementId, chosenSearchTerms(), el.attr("data-resource_id"));
      jQuery("#" + element.cleanId + "_text .ri_legend_container").append("<span id='" + element.cleanId + "_ani'class='highlighting'>highlighting... <img style='vertical-align: text-bottom;' src='/images/spinners/spinner_000000_16px.gif'></span>");
      element.highlightAnnotationPositions();
      el_text.attr("highlighted", "true");
    }
  });
});

// Get parameters from the URL
var BP_urlParams = {};
(function () {
  var match,
    pl = /\+/g,  // Regex for replacing addition symbol with a space
    search = /([^&=]+)=?([^&]*)/g,
    decode = function (s) {
      return decodeURIComponent(s.replace(pl, " "));
    },
    query = window.location.search.substring(1);
  queryH = window.location.hash.substring(1);

  while (match = search.exec(query)) {
    BP_urlParams[decode(match[1])] = decode(match[2]);
  }
  while (match = search.exec(queryH)) {
    BP_urlParams[decode(match[1])] = decode(match[2]);
  }
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
  //
  // TODO: may need to change the .split() on the classes params.
  //
  params["classes"] = (typeof params["classes"] !== "undefined") ? params["classes"].split(",") : undefined;
  BP_urlParams = params;
  if (typeof params["resourceId"] !== "undefined") {
    router.route("resource", params);
  } else if (typeof params["resources"] !== "undefined") {
    router.route("resources", params);
  }
}

function pushDisplayResource(url, params) {
  var route = "resource";
  if (bpResourceIndexEmbedded) {
    router.route(route, params);
  } else {
    params["route"] = route;
    History.pushState(params, document.title, url);
  }
}

function pushDisplayResources(url, params) {
  var route = "resources";
  if (bpResourceIndexEmbedded) {
    router.route(route, params);
  } else {
    params["route"] = route;
    History.pushState(params, document.title, url);
  }
}

function pushIndex() {
  var route = "index";
  if (bpResourceIndexEmbedded) {
    router.route(route);
  } else {
    History.pushState(null, document.title, "/resource_index");
  }
}

function replaceIndex() {
  var route = "index";
  if (bpResourceIndexEmbedded) {
    router.route(route);
  } else {
    History.replaceState(null, document.title, "/resource_index");
  }
}

// This will look up any term labels that haven't already been processed. If there are none it just exits without doing anything.
// To decrease ajax calls, we also use the bp_term_cache. This method is used via polling.
var bp_term_cache = {};
function lookupTermLabels() {
  jQuery("#resource_results a.ri_concept[data-applied_label='false']").each(function () {
    var link = jQuery(this);
    var params = { conceptid: link.data("concept_id"), ontologyid: link.data("ontology_id") };
    link.attr("data-applied_label", "true");

    // Check to see if another thread is already making an ajax request and start polling
    if (bp_term_cache[params.ontologyid + "/" + params.conceptid] === "getting") {
      return setTimeout((function () {
        return applyTermLabel(link, params);
      }), 100);
    }

    if (typeof bp_term_cache[params.ontologyid + "/" + params.conceptid] === "undefined") {
      bp_term_cache[params.ontologyid + "/" + params.conceptid] = "getting";
      jQuery.ajax({
        url     : "/ajax/json_term",
        data    : params,
        dataType: 'json',
        success : (function (link) {
          return function (data) {
            bp_term_cache[params.ontologyid + "/" + params.conceptid] = data;
            if (data !== null) jQuery(link).html(data.label);
          }
        })(this)
      });
    }
  })
}

// Poll for term information
jQuery(document).ready(function () {
  setInterval((function () {
    lookupTermLabels();
  }), 1000);
});

// This function will poll to see if term information exists
function applyTermLabel(link, params, calledAgain) {
  var term_info = bp_term_cache[params.ontologyid + "/" + params.conceptid];
  if (term_info === "getting") {
    if (typeof calledAgain !== "undefined") calledAgain = 0
    return setTimeout((function () {
      return applyTermLabel(link, params, calledAgain += 1);
    }), 100);
  }
  if (term_info !== null) jQuery(link).html(term_info.label);
}

function Router() {
  this.route = function (route, params) {
    switch (route) {
      case "index":
        this.index();
        break;
      case "resource":
        this.resource(params);
        break;
      case "resources":
        this.resources(params);
        break;
    }
  };

  this.index = function () {
    jQuery("#results").html("");
    jQuery("#results_error").html("");
    jQuery("#initial_resources").show();
    jQuery("#resource_index_terms_chzn .search-choice-close").click();
  };

  this.resource = function (params) {
    if (typeof params["classes"] === "undefined" || typeof params["resourceId"] === "undefined") {
      replaceIndex();
    }
    displayResource(params);
  };

  this.resources = function (params) {
    if (typeof params["classes"] === "undefined") {
      replaceIndex();
    }
    displayResources(params["classes"]);
  };

}
router = new Router();

function displayResource(params) {
  var resource = params["resourceId"];
  var resourceName = resources[resource].resourceName;
  // Only retrieve term information if this is an initial load
  if (jQuery("#resource_index_terms").val() !== null) {
    showResourceResults(resource, resourceName);
    return;
  }
  displayTerms(params["classes"], function () {
    showResourceResults(resource, resourceName);
  });
}

function displayResources(classes) {
  // Only retrieve term information if this is an initial load
  if (jQuery("#resource_index_terms").val() !== null) {
    showAllResources();
    return;
  }
  displayTerms(classes);
}

function displayTerms(classes, completedCallback) {
  var concept, conceptOpt, ontologyId, conceptId, ontologyName, conceptRetreivedCount, conceptsLength = classes.length, params;
  conceptRetreivedCount = 0;
  jQuery("#resource_index_terms").html("");
  for (var i = 0; i < conceptsLength; i++) {
    concept = classes[i];
    ontologyId = concept.split("/")[0];
    conceptId = concept.split("/")[1];
    ontologyName = ont_names[ontologyId];
    params = { ontologyid: ontologyId, conceptid: conceptId };
    jQuery.getJSON("/ajax/json_term", params, (function (ontologyName) {
      return function (data) {
        jQuery("#resource_index_terms").append(jQuery("<option/>").val(concept).html(" " + data.label + " <span class='search_ontology_acronym'>(" + ontologyName + ")</span>"));
        conceptRetreivedCount += 1;
        if (conceptRetreivedCount == conceptsLength) {
          for (var j = 0; j < conceptsLength; j++) {
            conceptOpt = classes[j];
            jQuery("#resource_index_terms option[value='" + conceptOpt + "']").attr("selected", true);
          }
          updateChosen();
          getSearchResults(completedCallback);
        }
      }
    })(ontologyName));
  }
}

function updateChosen() {
  jQuery("#resource_index_terms").trigger("liszt:updated");
  jQuery("#resource_index_terms").trigger("change");
}

function getSearchResults(success) {
  jQuery("#results_error").html("");
  jQuery("#resource_index_spinner").show();
  jQuery("#results.contains_search_results").hide();
  var params = {
    'classes': chosenSearchTerms() // ontologyURI: [classURI, classURI, ... ]
  };
  jQuery.ajax({
    type    : 'POST',
    url     : "/resource_index",
    data    : params,
    dataType: 'html',
    success : function (data) {
      jQuery("#results").html(data);
      jQuery("#results").addClass("contains_search_results");
      jQuery("#results.contains_search_results").show();
      jQuery("#results_container").show();
      jQuery("#resource_index_spinner").hide();
      if (success && typeof success === "function") {
        success();
      }
      jQuery("#initial_resources").hide();
      jQuery("#resource_table table").dataTable({
        "bPaginate": false,
        "bFilter"  : false,
        "aoData"   : [
          { "sType": "html" },
          { "sType": "html-formatted-num", "asSorting": [ "desc", "asc"] },
          { "sType": "percent", "asSorting": [ "desc", "asc"] },
          { "sType": "html-formatted-num", "asSorting": [ "desc", "asc"] }
        ]
      });
      // Update result counts for resources with matches
      updateCounts();
    },
    error   : function () {
      jQuery("#resource_index_spinner").hide();
      jQuery("#results_error").html("Problem retrieving search results, please try again");
    }
  })
}

function updateCounts() {
  var hiddenRows, totalRows, visibleRows;
  hiddenRows = jQuery("#resource_table table tbody tr.not_visible").length;
  totalRows = jQuery("#resource_table table tbody tr").length;
  visibleRows = totalRows - hiddenRows;
  jQuery("#result_counts").html("matches in " + visibleRows + " of " + totalRows + " resources")
}

jQuery("a.results_link").live("click", function (event) {
  var resource = jQuery(this).data("resource_id");
  //var resourceName = jQuery(this).data("resource_name");
  var url = "/resource_index/resources/" + resource + "?" + chosenSearchTermsToClassesArg();
  pushDisplayResource(url, {classes: chosenSearchTerms(), resourceId: resource});
});

jQuery("a#show_all_resources").live("click", function () {
  var url = "/resource_index/resources?" + chosenSearchTermsToClassesArg();
  pushDisplayResources(url, {classes: chosenSearchTerms()});
});

function showResourceResults(resource, resourceName) {
  jQuery(".resource_info").addClass("not_visible");
  jQuery("#resource_table").addClass("not_visible");
  jQuery("#resource_info_" + resource).removeClass("not_visible");
  jQuery("#resource_title").html(resourceName);
  jQuery(".resource_title").removeClass("not_visible");
  jQuery("#resource_title").removeClass("not_visible");
  updateCounts();
}

function showAllResources() {
  jQuery(".resource_info").addClass("not_visible");
  jQuery(".resource_title").addClass("not_visible");
  jQuery("#resource_title").addClass("not_visible");
  jQuery("#resource_table").removeClass("not_visible");
  updateCounts();
}

function Element(id, cleanId, classes, resource) {
  this.positions;
  this.id = id;
  this.cleanId = cleanId;
  this.jdomId = "#" + cleanId + "_text";
  this.classes = classes;
  this.resource = resource;
  this.loadAni = null;

  this.highlightAnnotationPositions = function () {
    var element = this;
    jQuery.ajax({
      url     : "/resource_index/element_annotations",
      data    : {
        elementid : this.id,
        classes: chosenSearchTermsToClassesArg(this.classes),
        resourceid: this.resource
      },
      dataType: "json",
      success : function (data) {
        element.positions = data;
        element.highlight();
      }
    });
  }

  this.highlight = function () {
    var element = this;
    jQuery.each(this.positions,
      function (contextName, positions) {
        var context = jQuery(element.jdomId + " p[data-context_name=" + contextName + "]");
        if (context.length !== 0) {
          highlighter = new PositionHighlighter();
          // Replace the current text with highlighted version
          context.html(highlighter.highlightUsingPosition(context.html(), positions));
        }
      }
    );
    jQuery("#" + this.cleanId + "_text").find(".highlighting").remove();
    if (this.loadAni !== null) {
      clearInterval(this.loadAni);
    }
  }
}

function PositionHighlighter() {
  this.offsetPositions = [];
  this.textToHighlight = "";

  this.highlightUsingPosition = function (text, positions) {
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
      this.addText("<span class='" + highlightType + "'>", startPosition, -1);
      // Add the highlight closer
      this.addText("</span>", endPosition, 0);
    }

    return this.textToHighlight;
  }

  this.updatePositions = function (start, added_count) {
    var offset_length = this.offsetPositions.length;
    for (var i = start; i <= offset_length; i++) {
      this.offsetPositions[i] += added_count;
    }
  }

  this.addText = function (textToAdd, position, offset) {
    this.textToHighlight = [this.textToHighlight.slice(0, this.getActualPosition(position) + offset), textToAdd, this.textToHighlight.slice(this.getActualPosition(position) + offset)].join('');
    this.updatePositions(position, textToAdd.length);
  }

  this.getActualPosition = function (position) {
    return position + this.offsetPositions[position];
  }
}

function currentOntologyIds() {
  var selectedOntIds = jQuery("#ontology_ontologyId").val();
  return selectedOntIds === null || selectedOntIds === "" ? ont_ids : selectedOntIds;
}

//function currentConceptIds() {
//  var conceptIds = jQuery("#resource_index_terms").val();
//  if (typeof conceptIds === "string") {
//    conceptIds = conceptIds.split(",");
//  }
//  return conceptIds;
//}


function chosenSearchTerms() {
  var chosenTermsMap = {};
  // get selected option values, an array of combined_uri strings.
  var combined_uris = jQuery("#resource_index_terms").val();
  if (typeof combined_uris === "string") {
    combined_uris = combined_uris.split(); // coerce it to an Array
  }
  for(var i=0; i < combined_uris.length; i++){
    var combined_uri = combined_uris[i];
    var split_uris = uri_split(combined_uri);
    var chosen_ont_uri = split_uris[0];
    var chosen_cls_uri = split_uris[1];
    if(! chosenTermsMap.hasOwnProperty(chosen_ont_uri)) {
      chosenTermsMap[chosen_ont_uri] = new Array();
    }
    chosenTermsMap[chosen_ont_uri].push(chosen_cls_uri);
  };
  return chosenTermsMap;
}

function chosenSearchTermsToClassesArg(chosenTermsMap) {
  if (chosenTermsMap === undefined){
    chosenTermsMap = chosenSearchTerms();
  }
  var chosenClassesURI = "";
  for (var ont_uri in chosenTermsMap) {
    var chosenClassArr = chosenTermsMap[ont_uri];
    chosenClassesURI += "classes[" + encodeURIComponent(ont_uri) + "]=";
    chosenClassesURI += encodeURIComponent(chosenClassArr.join(','));
    chosenClassesURI += "&";
  }
  return chosenClassesURI.slice(0,-1); // remove last '&'
}

