var annotationsTable;
var bp_last_params;

var BP_COLUMNS = { terms: 0, ontologies: 1, types: 2, sem_types: 3, matched_terms: 5, matched_ontologies: 6 };

var CONCEPT_MAP = { "mapping": "mappedConcept", "mgrep": "concept", "closure": "concept" };

function insertSampleText() {
  "use strict";
  var text = "Melanoma is a malignant tumor of melanocytes which are found predominantly in skin but also in the bowel and the eye.";
  jQuery("#annotation_text").focus();
  jQuery("#annotation_text").val(text);
}

function get_annotations() {
  jQuery("#results_error").html("");
  jQuery("#annotator_error").html("");

  // Validation
  if (jQuery("#annotation_text").val() === jQuery("#annotation_text").attr("title")) {
    jQuery("#annotator_error").html("Please enter text to annotate");
    return;
  }

  // Really dumb, basic word counter. Counts spaces.
  if (jQuery("#annotation_text").val().match(/ /g) !== null && jQuery("#annotation_text").val().match(/ /g).length > 500) {
    jQuery("#annotator_error").html("Please use less than 500 words. If you need to annotate larger pieces of text you can use the <a href='http://www.bioontology.org/wiki/index.php/Annotator_User_Guide' target='_blank'>Annotator Web Service</a>");
    return;
  }

  jQuery("#annotations_container").hide(300);
  jQuery(".annotator_spinner").show();

  var params = {},
    ont_select = jQuery("#ontology_ontologyId"),
    mappings = [];

  params.ontology_ids = (ont_select.val() === null) ? "" : ont_select.val().join(",");
  params.text = jQuery("#annotation_text").val();

  if (jQuery("#wholeWordOnly:checked").val() !== "undefined") {
    params.wholeWordOnly = jQuery("#wholeWordOnly:checked").val();
  }

  if (jQuery("#semanticTypes").val() !== null) {
    params.semanticTypes = jQuery("#semanticTypes").val();
    annotationsTable.fnSetColumnVis(BP_COLUMNS.sem_types, true);
    jQuery("#results_error").html("Only results from ontologies with semantic types available are displayed");
  } else {
    annotationsTable.fnSetColumnVis(BP_COLUMNS.sem_types, false);
  }

  params.levelMax = jQuery("#levelMax").val();

  jQuery("[name='mappings']:checked").each(function () {
    mappings.push(jQuery(this).val());
  });
  params.mappingTypes = mappings;

  jQuery.ajax({
    type    : "POST",
    url     : "/annotator",  // Call back to the UI annotation_controller::create method
    data    : params,
    dataType: "json",
    success : function (data) {
      display_annotations(data, params);
      jQuery(".annotator_spinner").hide();
      jQuery("#annotations_container").show(600);
      //jQuery("#annotator_error").html(" Success in getting annotations; TODO: format for web page.");
    },
    error   : function (data) {
      //console.log(data);
      jQuery(".annotator_spinner").hide();
      jQuery("#annotations_container").hide(600);
      jQuery("#annotator_error").html(" Problem getting annotations, please try again");
    }
  });


  /*
   // OLD API

   jQuery.ajax({
   type: "POST",
   url: "/annotator",
   data: params,
   dataType: "json",
   success: function (data) {
   var results = [],
   resultCount = 1,
   ontologies = {},
   terms = {},
   match_types = {},
   matched_ontologies = {},
   matched_terms = {},
   context_map = { "mgrep": "direct", "mapping": "mapping", "closure": "ancestor" };

   // There may be no data.statistics object in the new API.
   //bp_last_params = data.statistics.parameters;
   bp_last_params = params; // Does this work instead?

   // There may be no data.annotations object in the new API.
   if (!jQuery.isEmptyObject(data.annotations)) {
   jQuery(data.annotations).each(function () {
   var annotation = this;
   var ontology_name = data.ontologies[annotation.concept.localOntologyId].name;
   var concept_name = annotation.concept.preferredName;
   var context_name = annotation.context.contextName;
   var matched_concept = context_name == "MGREP" ? annotation.concept : annotation.context[CONCEPT_MAP[context_name.toLowerCase()]];
   var matched_ontology_name = data.ontologies[matched_concept.localOntologyId].name;

   // Gather sem types for display
   var semantic_types = [];
   jQuery.each(annotation.concept.semantic_types, function () {
   semantic_types.push(this.description);
   });

   // Create an array representing the row in the table
   var row = [
   "<a href='/ontologies/" + annotation.concept.localOntologyId + "?p=terms&conceptid=" + encodeURIComponent(annotation.concept.fullId) + "'>" + annotation.concept.preferredName + "</a>",
   "<a href='/ontologies/" + annotation.concept.localOntologyId + "'>" + ontology_name + "</a>",
   context_map[annotation.context.contextName.toLowerCase()],
   semantic_types.join("<br/>"),
   annotation.context.highlight,
   "<a href='/ontologies/" + matched_concept.localOntologyId + "?p=terms&conceptid=" + encodeURIComponent(matched_concept.fullId) + "'>" + matched_concept.preferredName + "</a>",
   "<a href='/ontologies/" + matched_concept.localOntologyId + "'>" + matched_ontology_name + "</a>"
   ];
   results.push(row);
   resultCount++;
   // Keep track of how many results are associated with each ontology
   ontologies[ontology_name] = (ontology_name in ontologies) ? ontologies[ontology_name] + 1 : 1;

   // Keep track of how many results are associated with each term
   terms[concept_name.toLowerCase()] = (concept_name.toLowerCase() in terms) ? terms[concept_name.toLowerCase()] + 1 : 1;

   // Keep track of match types
   match_types[context_map[annotation.context.contextName.toLowerCase()]] = (context_map[annotation.context.contextName.toLowerCase()] in match_types) ? match_types[context_map[annotation.context.contextName.toLowerCase()]] + 1 : 1;

   // Keep track of matched terms
   matched_terms[matched_concept.preferredName.toLowerCase()] = (matched_concept.preferredName.toLowerCase() in matched_terms) ? matched_terms[matched_concept.preferredName.toLowerCase()] + 1 : 1;

   // Keep track of matched ontologies
   matched_ontologies[matched_ontology_name] = (matched_ontology_name in matched_ontologies) ? matched_ontologies[matched_ontology_name] + 1 : 1;
   });
   }

   // Add result counts
   //var total_count = data.statistics.mgrep + data.statistics.mapping + data.statistics.closure;
   //jQuery("#result_counts").html("total results " + " <span class='result_count'>" + total_count + "</span>&nbsp;&nbsp;&nbsp;&nbsp;(");
   //jQuery("#result_counts").append(context_map["mgrep"] + " <span class='result_count'>" + data.statistics.mgrep + "</span>");
   //jQuery("#result_counts").append("&nbsp;&nbsp;/&nbsp;&nbsp;" + context_map["closure"] + " <span class='result_count'>" + data.statistics.closure + "</span>");
   //jQuery("#result_counts").append("&nbsp;&nbsp;/&nbsp;&nbsp;" + context_map["mapping"] + " <span class='result_count'>" + data.statistics.mapping + "</span>");
   //jQuery("#result_counts").append(")");

   // Add checkboxes to filters
   createFilterCheckboxes(ontologies, "filter_ontology_checkboxes", "ontology_filter_list");
   createFilterCheckboxes(terms, "filter_terms_checkboxes", "terms_filter_list");
   createFilterCheckboxes(match_types, "filter_match_type_checkboxes", "match_type_filter_list");
   createFilterCheckboxes(matched_ontologies, "filter_matched_ontology_checkboxes", "matched_ontology_filter_list");
   createFilterCheckboxes(matched_terms, "filter_matched_terms_checkboxes", "matched_terms_filter_list");

   // Add links for downloading results
   annotatorPostForm("tabDelimited");
   annotatorPostForm("text");
   annotatorPostForm("xml");

   // Reset table
   annotationsTable.fnClearTable();
   annotationsTable.fnSortNeutral();
   removeFilters();

   // Generate parameters for list at bottom of page
   generateParameters();

   // Need to re-init because we're not using "live" because of propagation issues
   filter_ontologies.init();
   filter_terms.init();
   filter_match_type.init();
   filter_matched_ontologies.init();
   filter_matched_terms.init();

   // Add data
   annotationsTable.fnAddData(results);

   jQuery("#annotations_container").show(600, jQuery(".annotator_spinner").hide());
   },
   error: handleAnnotatorError
   });

   // OLD API
   */

} // get_annotations


var displayFilteredColumnNames = function () {
  "use strict";
  var column_names = [];
  jQuery(".bp_popup_list input:checked").closest("th").each(function () {
    column_names.push(jQuery(this).attr("title"));
  });
  jQuery("#filter_names").html(column_names.join(", "));
  if (column_names.length > 0) {
    jQuery("#filter_list").show();
  } else {
    jQuery("#filter_list").hide();
  }
};

function createFilterCheckboxes(filter_items, checkbox_class, checkbox_location) {
  "use strict";
  var for_sort = [], sorted = [];

  // Sort ontologies by number of results
  jQuery.each(filter_items, function (k, v) {
    for_sort.push({label: k + " (" + v + ")", count: v, value: k, value_encoded: encodeURIComponent(k)});
  });
  for_sort.sort(function (a, b) {
    return jQuery.trim(a.label) > jQuery.trim(b.label)
  });

  // Create checkboxes for ontology filter
  jQuery.each(for_sort, function () {
    var checkbox = jQuery("<input/>").attr("class", checkbox_class).attr("type", "checkbox").attr("value", this.value).attr("id", checkbox_class + this.value_encoded);
    var label = jQuery("<label/>").attr("for", checkbox_class + this.value_encoded).html(" " + this.label);
    sorted.push(jQuery("<span/>").append(checkbox).append(label).html());
  });
  jQuery("#" + checkbox_location).html(sorted.join("<br/>"));
}

var filter_ontologies = {
  init: function () {
    "use strict";
    jQuery("#filter_ontologies").bind("click", function (e) {
      bp_popup_init(e)
    });
    // Need to use bind to avoid "live" propogation issues
    jQuery(".filter_ontology_checkboxes").bind("click", function (e) {
      filter_ontologies.filterOntology(e)
    });
    jQuery("#ontology_filter_list").click(function (e) {
      e.stopPropagation()
    });
    this.cleanup();
  },

  cleanup: function () {
    "use strict";
    jQuery("html").click(bp_popup_cleanup);
    jQuery(document).keyup(function (e) {
      if (e.keyCode == 27) {
        bp_popup_cleanup();
      } // esc
    });
  },

  filterOntology: function (e) {
    "use strict";
    e.stopPropagation();
    var search_regex = [];
    jQuery(".filter_ontology_checkboxes:checked").each(function () {
      search_regex.push(jQuery(this).val());
    });
    displayFilteredColumnNames();
    if (search_regex.length === 0) {
      annotationsTable.fnFilter("", BP_COLUMNS.ontologies);
    } else {
      annotationsTable.fnFilter(search_regex.join("|"), BP_COLUMNS.ontologies, true, false);
    }
  }
};

var filter_terms = {
  init: function () {
    "use strict";
    jQuery("#filter_terms").bind("click", function (e) {
      bp_popup_init(e)
    });
    // Need to use bind to avoid "live" propogation issues
    jQuery(".filter_terms_checkboxes").bind("click", function (e) {
      filter_terms.filterTerms(e)
    });
    jQuery("#terms_filter_list").click(function (e) {
      e.stopPropagation()
    });
    this.cleanup();
  },

  cleanup: function () {
    "use strict";
    jQuery("html").click(bp_popup_cleanup);
    jQuery(document).keyup(function (e) {
      if (e.keyCode == 27) {
        bp_popup_cleanup();
      } // esc
    });
  },

  filterTerms: function (e) {
    "use strict";
    e.stopPropagation();
    var search_regex = [];
    jQuery(".filter_terms_checkboxes:checked").each(function () {
      // Escape characters used in regex
      search_regex.push(jQuery(this).val().replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"));
    });
    displayFilteredColumnNames();
    if (search_regex.length === 0) {
      annotationsTable.fnFilter("", BP_COLUMNS.terms);
    } else {
      annotationsTable.fnFilter("^" + search_regex.join("(?!.)|^") + "(?!.)", BP_COLUMNS.terms, true, false);
    }
  }
};

var filter_matched_ontologies = {
  init: function () {
    "use strict";
    jQuery("#filter_matched_ontologies").bind("click", function (e) {
      bp_popup_init(e);
    });
    // Need to use bind to avoid "live" propogation issues
    jQuery(".filter_matched_ontology_checkboxes").bind("click", function (e) {
      filter_matched_ontologies.filter(e);
    });
    jQuery("#ontology_matched_filter_list").click(function (e) {
      e.stopPropagation();
    });
    this.cleanup();
  },

  cleanup: function () {
    "use strict";
    jQuery("html").click(bp_popup_cleanup);
    jQuery(document).keyup(function (e) {
      if (e.keyCode == 27) {
        bp_popup_cleanup();
      } // esc
    });
  },

  filter: function (e) {
    "use strict";
    e.stopPropagation();
    var search_regex = [];
    jQuery(".filter_matched_ontology_checkboxes:checked").each(function () {
      search_regex.push(jQuery(this).val());
    });
    displayFilteredColumnNames();
    if (search_regex.length === 0) {
      annotationsTable.fnFilter("", BP_COLUMNS.matched_ontologies);
    } else {
      annotationsTable.fnFilter(search_regex.join("|"), BP_COLUMNS.matched_ontologies, true, false);
    }
  }
};

var filter_matched_terms = {
  init: function () {
    "use strict";
    jQuery("#filter_matched_terms").bind("click", function (e) {
      bp_popup_init(e)
    });
    // Need to use bind to avoid "live" propogation issues
    jQuery(".filter_matched_terms_checkboxes").bind("click", function (e) {
      filter_matched_terms.filter(e)
    });
    jQuery("#matched_terms_filter_list").click(function (e) {
      e.stopPropagation()
    });
    this.cleanup();
  },

  cleanup: function () {
    "use strict";
    jQuery("html").click(bp_popup_cleanup);
    jQuery(document).keyup(function (e) {
      if (e.keyCode == 27) {
        bp_popup_cleanup();
      } // esc
    });
  },

  filter: function (e) {
    "use strict";
    e.stopPropagation();
    var search_regex = [];
    jQuery(".filter_matched_terms_checkboxes:checked").each(function () {
      // Escape characters used in regex
      search_regex.push(jQuery(this).val().replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"));
    });
    displayFilteredColumnNames();
    if (search_regex.length === 0) {
      annotationsTable.fnFilter("", BP_COLUMNS.matched_terms);
    } else {
      annotationsTable.fnFilter("^" + search_regex.join("(?!.)|^") + "(?!.)", BP_COLUMNS.matched_terms, true, false);
    }
  }
};

var filter_match_type = {
  init: function () {
    "use strict";
    jQuery("#filter_match_type").bind("click", function (e) {
      bp_popup_init(e)
    });
    // Need to use bind to avoid "live" propogation issues
    jQuery(".filter_match_type_checkboxes").bind("click", function (e) {
      filter_match_type.filterMatchType(e)
    });
    jQuery("#match_type_filter_list").click(function (e) {
      e.stopPropagation()
    });
    this.cleanup();
  },

  cleanup: function () {
    "use strict";
    jQuery("html").click(bp_popup_cleanup);
    jQuery(document).keyup(function (e) {
      if (e.keyCode == 27) {
        bp_popup_cleanup();
      } // esc
    });
  },

  filterMatchType: function (e) {
    "use strict";
    e.stopPropagation();
    var search_regex = [];
    jQuery(".filter_match_type_checkboxes:checked").each(function () {
      // Escape characters used in regex
      search_regex.push(jQuery(this).val().replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"));
    });
    displayFilteredColumnNames();
    if (search_regex.length === 0) {
      annotationsTable.fnFilter("", BP_COLUMNS.types);
    } else {
      annotationsTable.fnFilter("^" + search_regex.join("(?!.)|^") + "(?!.)", BP_COLUMNS.types, true, false);
    }
  }
};

var removeFilters = function () {
  "use strict";
  jQuery(".filter_ontology_checkboxes").attr("checked", false);
  jQuery(".filter_terms_checkboxes").attr("checked", false);
  jQuery(".filter_match_type_checkboxes").attr("checked", false);
  jQuery(".filter_matched_terms_checkboxes").attr("checked", false);
  jQuery(".filter_matched_ontologies_checkboxes").attr("checked", false);
  annotationsTable.fnFilter("", BP_COLUMNS.terms);
  annotationsTable.fnFilter("", BP_COLUMNS.ontologies);
  annotationsTable.fnFilter("", BP_COLUMNS.types);
  annotationsTable.fnFilter("", BP_COLUMNS.matched_terms);
  annotationsTable.fnFilter("", BP_COLUMNS.matched_ontologies);
  jQuery("#filter_list").hide();
};

// Datatables reset sort extension
jQuery.fn.dataTableExt.oApi.fnSortNeutral = function (oSettings) {
  "use strict";
  /* Remove any current sorting */
  oSettings.aaSorting = [];
  /* Sort display arrays so we get them in numerical order */
  oSettings.aiDisplay.sort(function (x, y) {
    return x - y;
  });
  oSettings.aiDisplayMaster.sort(function (x, y) {
    return x - y;
  });
  /* Redraw */
  oSettings.oApi._fnReDraw(oSettings);
};

// Creates an HTML form with a button that will POST to the annotator
function annotatorPostForm(format) {
  "use strict";
  var format_map = { "xml": "XML", "text": "Text", "tabDelimited": "CSV" };
  var params = bp_last_params;
  params["format"] = format;

  var form_fields = [];
  jQuery.each(params, function (k, v) {
    if (v != null) {
      form_fields.push("<input type='hidden' name='" + k + "' value='" + v + "'>");
    }
  });

  var form = jQuery("<form action='http://" + jQuery("#annotations_container").data("bp_rest_server") + "/annotator/annotator' method='post' target='_blank'/>")
    .append(form_fields.join(""))
    .append("<input type='submit' value='" + format_map[format] + "'>");

  jQuery("#download_links_" + format.toLowerCase()).html(form);
}

function generateParameters() {
  "use strict";
  var params = [];
  var new_params = jQuery.extend(true, {}, bp_last_params);
  delete new_params["apikey"]
  delete new_params["format"]
  jQuery.each(new_params, function (k, v) {
    if (v != null && v !== "") {
      params.push(k + "=" + v);
    }
  });
  jQuery("#annotator_parameters").html(params.join("&"));
}

jQuery(document).ready(function () {
  "use strict";
  jQuery("#annotator_button").click(get_annotations);
  jQuery("#semanticTypes").chosen({search_contains: true});
  jQuery("#insert_text_link").click(insertSampleText);
  // Init annotation table
  annotationsTable = jQuery("#annotations").dataTable({
    bPaginate  : false,
    bAutoWidth : false,
    aaSorting  : [],
    oLanguage  : { sZeroRecords: "No annotations found" },
    "aoColumns": [
      { "sWidth": "15%" },
      { "sWidth": "15%" },
      { "sWidth": "5%" },
      { "sWidth": "5%", "bVisible": false },
      { "sWidth": "30%" },
      { "sWidth": "15%" },
      { "sWidth": "15%" }
    ]
  });
  filter_ontologies.init();
  filter_terms.init();
  filter_match_type.init();
  filter_matched_ontologies.init();
  filter_matched_terms.init();
}); // doc ready


// ***************************************
// TEST JAVASCRIPT FOR PARSING NEW API JSON

// http://stagedata.bioontology.org/annotator?text=Melanoma+is+a+malignant+tumor+of+melanocytes+which+are+found+predominantly+in+skin+but+also+in+the+bowel+and+the+eye

//var text = "Melanoma is a malignant tumor of melanocytes which are found predominantly in skin but also in the bowel and the eye.";

//function request_details(uri, propertyArray) {
//  var obj = {};
//  $.ajax({
//    url: uri,
//    datatype: 'json',
//    async: false,
//    success: function(json){
//obj.name = json.name;
//      var i = null;
//      var jsonProperties = Object.keys(json); // ['name', 'value']
//      jsonProperties.forEach(function (key) {
//        i = $.inArray(key, propertyArray);
//        if ( i > -1 ){
// this key:value pair has been requested
//          obj[key] = json[key];
//        }
//      });
//    },
//  });
//  return obj;
//}


function get_link(uri, label) {
  "use strict";
  return '<a href="' + uri + '">' + label + '</a>';
}


//function get_class_details(uri) {
//  "use strict";
//  var details = {};
//  $.ajax({
//    url     : uri,
//    datatype: 'json',
//    async   : false,
//    success : function (json) {
//      details.prefLabel = json.prefLabel;
//      //details.synonym = json.synonym;
//    }
//  });
//  return details;
//  // NOTE: Cute abstraction, but it's slower.
//  //return request_details(uri, ["name"]);
//}


//function get_ontology_details(uri) {
//  "use strict";
//  var details = {};
//  $.ajax({
//    url     : uri,
//    datatype: 'json',
//    async   : false,
//    success : function (json) {
//      details.name = json.name;
//    }
//  });
//  return details;
//  // NOTE: Cute abstraction, but it's slower.
//  //return request_details(uri, ["name"]);
//}


//function process_class(term) {
//  "use strict";
//  // Get class URI and prefLabel
//  // Use the '@id' value?
//  var cls = {},
//    details = null;
//  cls.uri = term.links.self;
//  // TODO: Use the annotator_controller.create method to get this detail.
//  //details = get_class_details(cls.uri + "?apikey=" + apikey);
//  cls.prefLabel = "TODO: GET IT IN ANNOTATOR CONTROLLER?";
//  //cls.synonym = details.synonym;
//  return cls;
//}


//function process_class_ontology(term) {
//  "use strict";
//  // Get ontology URI and name
//  // Use the '@id' value?
//  var ont = {},
//    details = null;
//  ont.uri = term.links.ontology;
//  // TODO: Use the annotator_controller.create method to get this detail.
//  //details = get_ontology_details(ont.uri + "?apikey=" + apikey);
//  ont.name = "TODO: GET IT IN ANNOTATOR CONTROLLER?";
//  return ont;
//}


function process_annotation(annotation, text) {
  "use strict";
  var cls = annotation.annotatedClass,
    ont = cls.ontology,
    rows = "",
    cls_cell = "<td>" + get_link(cls.uri, cls.prefLabel) + "</td>",
    ont_cell = "<td>" + get_link(ont.uri, ont.name) + "</td>",
    text_match = null,
    text_prefix = null,
    text_suffix = null,
    text_markup = null;
  $.each(annotation.annotations, function (i, a) {
    rows += "<tr>";
    rows += cls_cell + ont_cell;
    text_match = text.substring(a.from - 1, a.to);
    text_prefix = text.substring(0, a.from - 1);
    text_suffix = text.substring(a.to);
    text_markup = text_prefix + "<em>" + text_match + "</em>" + text_suffix;
    //console.log('text markup: ' + text_markup);
    rows += "<td>" + text_markup + "</td>";
    rows += cls_cell + ont_cell;
    rows += "</tr>";
    // Add rows for any classes in the hierarchy.
    var c = null, o = null;
    $.each(annotation.hierarchy, function (i, h) {
      c = h.annotatedClass;
      o = c.ontology;
      rows += "<tr>";
      rows += "<td>" + get_link(c.uri, c.prefLabel) + "</td>";
      rows += "<td>" + get_link(o.uri, o.name) + "</td>";
      rows += "<td>" + text_markup + "</td>";
      rows += cls_cell + ont_cell;
      rows += "</tr>";
    }); // hierarchy loop
    // TODO: Add rows for any classes in the mappings.
    // Note that the ont_cell will be different.
  }); // annotations loop
  return rows;
}

function display_annotations(data, params) {
  "use strict";
  var output = "<h2>Annotator rows:</h2>";
  output += "<table cellpadding='5'>";
  for (var i = 0; i < data.length; i++) {
    output += process_annotation(data[i], params.text);
  }
  output += "</table>";
  jQuery("#annotations_container").html(output);
}


