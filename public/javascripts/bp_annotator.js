var annotationsTable;
var bp_last_params;

// Note: the configuration is in config/bioportal_config.rb.
var BP_CONFIG = jQuery(document).data().bp.config;

var BP_COLUMNS = { terms: 0, ontologies: 1, types: 2, sem_types: 3, matched_terms: 5, matched_ontologies: 6 };

var CONCEPT_MAP = { "mapping": "mappedConcept", "mgrep": "concept", "closure": "concept" };

function set_last_params(params) {
  bp_last_params = params;
  bp_last_params.apikey = BP_CONFIG.apikey;// TODO: get the user apikey?
  //console.log(bp_last_params);
}

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

  // Really dumb, basic word counter.
  if (jQuery("#annotation_text").val().split(' ').length > 500) {
    jQuery("#annotator_error").html("Please use less than 500 words. If you need to annotate larger pieces of text you can use the <a href='http://www.bioontology.org/wiki/index.php/Annotator_User_Guide' target='_blank'>Annotator Web Service</a>");
    return;
  }

  jQuery("#annotations_container").hide();
  jQuery(".annotator_spinner").show();

  var params = {},
    ont_select = jQuery("#ontology_ontologyId"),
    mappings = [];

  params.text = jQuery("#annotation_text").val();
  params.max_level = jQuery("#max_level").val();
  params.ontologies = (ont_select.val() === null) ? [] : ont_select.val();

  // Use the annotator default for wholeWordOnly = true.
  //if (jQuery("#wholeWordOnly:checked").val() !== undefined) {
  //  params.wholeWordOnly = jQuery("#wholeWordOnly:checked").val();
  //}

  if (jQuery("#semanticTypes").val() !== null) {
    params.semanticTypes = jQuery("#semanticTypes").val();
    annotationsTable.fnSetColumnVis(BP_COLUMNS.sem_types, true);
    jQuery("#results_error").html("Only results from ontologies with semantic types available are displayed.");
  } else {
    annotationsTable.fnSetColumnVis(BP_COLUMNS.sem_types, false);
  }

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
      set_last_params(params);
      display_annotations(data, bp_last_params);
      jQuery(".annotator_spinner").hide(200);
      jQuery("#annotations_container").show(300);
    },
    error   : function (data) {
      set_last_params(params);
      jQuery(".annotator_spinner").hide(200);
      jQuery("#annotations_container").hide();
      jQuery("#annotator_error").html(" Problem getting annotations, please try again");
    }
  });

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


function annotatorFormatLink(param_string, format) {
  "use strict";
  // TODO: Check whether 'text' and 'tabDelimited' could work.
  // For now, assume that json and xml will work or should work.
  var format_map = { "json": "JSON", "xml": "XML", "text": "Text", "tabDelimited": "CSV" };
  var query = BP_CONFIG.rest_url + "annotator?apikey=" + BP_CONFIG.apikey + "&" + param_string;
  if (format !== 'json') {
    query += "&format=" + format;
  }
  var link = "<a href='" + encodeURI(query) + "' target='_blank'>" + format_map[format] + "</a>";
  jQuery("#download_links_" + format.toLowerCase()).html(link);
}

function generateParameters() {
  "use strict";
  var params = [];
  var new_params = jQuery.extend(true, {}, bp_last_params); // deep copy
  delete new_params["apikey"];
  delete new_params["format"];
  //console.log(new_params);
  jQuery.each(new_params, function (k, v) {
    if (v !== null && v !== undefined && v !== "" && v.length > 0) {
      params.push(k + "=" + v);
    }
  });
  return params.join("&");
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


function get_link(uri, label) {
  "use strict";
  return '<a href="' + uri + '">' + label + '</a>';
}


function get_annotation_rows(annotation, text) {
  "use strict";
  var match_type_translation = { "mgrep": "direct", "mapping": "mapping", "closure": "ancestor" };
  var result = {},
    cls = annotation.annotatedClass,
    rows = [],
    cells = [],
    cls_rel_ui = null,
    ont_rel_ui = null,
    cls_link = null,
    ont_link = null,
    match_type = '',
    semantic_types = cls.semanticType.join('; '),// test with 'abscess' text and sem type = T046,T020
    text_match = null,
    text_prefix = null,
    text_suffix = null,
    text_markup = null;
  // Extract relative URIs
  cls_rel_ui = cls.ui.replace(/^.*\/\/[^\/]+/, '');
  ont_rel_ui = cls_rel_ui.replace(/\?p=terms.*$/, '?p=summary');
  cls_link = get_link(cls_rel_ui, cls.prefLabel);
  ont_link = get_link(ont_rel_ui, cls.ontology.name);
  var match_span = '<span style="color: rgb(153,153,153);">';
  var match_markup_span = '<span style="color: rgb(35, 73, 121); font-weight: bold; padding: 2px 0px;">';
  jQuery.each(annotation.annotations, function (i, a) {

    // TODO: consider string truncation around the annotation markups.

    text_match = text.substring(a.from - 1, a.to);
    text_prefix = text.substring(0, a.from - 1);
    text_suffix = text.substring(a.to);
    text_markup = match_markup_span + text_match + "</span>";
    text_markup = match_span + text_prefix + text_markup + text_suffix + "</span>";
    //console.log('text markup: ' + text_markup);
    match_type = match_type_translation[a.matchType.toLowerCase()] || 'direct';
    cells = [ cls_link, ont_link, match_type, semantic_types, text_markup, cls_link, ont_link ];
    rows.push(cells);
    // Add rows for any classes in the hierarchy.
    match_type = 'ancestor';
    var c = null, o = null,
      h_cls_link = null, h_ont_link = null,
      c_rel_ui = null, o_rel_ui = null;
    jQuery.each(annotation.hierarchy, function (i, h) {
      c = h.annotatedClass;
      c_rel_ui = c.ui.replace(/^.*\/\/[^\/]+/, '');
      o_rel_ui = c_rel_ui.replace(/\?p=terms.*$/, '?p=summary');
      h_cls_link = get_link(c_rel_ui, c.prefLabel);
      h_ont_link = get_link(o_rel_ui, c.ontology.name);
      cells = [ h_cls_link, h_ont_link, match_type, semantic_types, text_markup, cls_link, ont_link ];
      rows.push(cells);
    }); // hierarchy loop
    // TODO: Add rows for any classes in the mappings.
    // Note that the ont_link will be different.
  }); // annotations loop
  return rows;
}


function update_annotations_table(rowsArray) {
  "use strict";
  var ontologies = {},
    terms = {},
    match_types = {},
    matched_ontologies = {},
    matched_terms = {};

  jQuery(rowsArray).each(function () {
    // [ cls_link, ont_link, match_type, semantic_types, text_markup, cls_link, ont_link ];
    var row = this,
      cls_link = row[0],
      ont_link = row[1],
      match_type = row[2],// direct, ancestors, mapping
      //semantic_type = row[3],
      //match_text = row[4],
      match_cls_link = row[5],
      match_ont_link = row[6];
    // Extract labels from links (using non-greedy regex).
    var cls_label = cls_link.replace(/^<a.*?>/,'').replace('</a>','').toLowerCase(),
      ont_label = ont_link.replace(/^<a.*?>/,'').replace('</a>',''),
      match_cls_label = match_cls_link.replace(/^<a.*?>/,'').replace('</a>','').toLowerCase(),
      match_ont_label = match_ont_link.replace(/^<a.*?>/,'').replace('</a>','');

    // TODO: Gather sem types for display
//    var semantic_types = [];
//    jQuery.each(annotation.concept.semantic_types, function () {
//      semantic_types.push(this.description);
//    });

    // Keep track of how many results are associated with each ontology
    ontologies[ont_label] = (ont_label in ontologies) ? ontologies[ont_label] + 1 : 1;
    // Keep track of how many results are associated with each term
    terms[cls_label] = (cls_label in terms) ? terms[cls_label] + 1 : 1;
    // Keep track of match types
    match_types[match_type] = (match_type in match_types) ? match_types[match_type] + 1 : 1;
    // Keep track of matched terms
    matched_terms[match_cls_label] = (match_cls_label in matched_terms) ? matched_terms[match_cls_label] + 1 : 1;
    // Keep track of matched ontologies
    matched_ontologies[match_ont_label] = (match_ont_label in matched_ontologies) ? matched_ontologies[match_ont_label] + 1 : 1;
  });

  // Add result counts
  var count_span = '<span class="result_count">'
  jQuery("#result_counts").html("total results " + count_span + rowsArray.length + "</span>&nbsp;");
  var direct_count = ("direct" in match_types) ? match_types["direct"] : 0,
    ancestor_count = ("ancestor" in match_types) ? match_types["ancestor"] : 0,
    mapping_count = ("mapping" in match_types) ? match_types["mapping"] : 0;
  jQuery("#result_counts").append("(");
  jQuery("#result_counts").append("direct " + count_span  + direct_count + "</span>");
  jQuery("#result_counts").append("&nbsp;/&nbsp;" + "ancestor " + count_span + ancestor_count + "</span>");
  jQuery("#result_counts").append("&nbsp;/&nbsp;" + "mapping " + count_span + mapping_count + "</span>");
  jQuery("#result_counts").append(")");

  // Add checkboxes to filters
  createFilterCheckboxes(ontologies, "filter_ontology_checkboxes", "ontology_filter_list");
  createFilterCheckboxes(terms, "filter_terms_checkboxes", "terms_filter_list");
  createFilterCheckboxes(match_types, "filter_match_type_checkboxes", "match_type_filter_list");
  createFilterCheckboxes(matched_ontologies, "filter_matched_ontology_checkboxes", "matched_ontology_filter_list");
  createFilterCheckboxes(matched_terms, "filter_matched_terms_checkboxes", "matched_terms_filter_list");

  // Reset table
  annotationsTable.fnClearTable();
  annotationsTable.fnSortNeutral();
  removeFilters();

  // Need to re-init because we're not using "live" because of propagation issues
  filter_ontologies.init();
  filter_terms.init();
  filter_match_type.init();
  filter_matched_ontologies.init();
  filter_matched_terms.init();

  // Add data
  annotationsTable.fnAddData(rowsArray);
}

function display_annotations(annotations, params) {
  "use strict";
  var all_rows = [];
  for (var i = 0; i < annotations.length; i++) {
    all_rows = all_rows.concat( get_annotation_rows(annotations[i], params.text) );
  }
  update_annotations_table(all_rows);
  // Generate parameters for list at bottom of page
  var param_string = generateParameters(); // uses bp_last_param
  jQuery("#annotator_parameters").html(param_string);
  // Add links for downloading results
  //annotatorFormatLink("tabDelimited");
  annotatorFormatLink(param_string, "json");
  annotatorFormatLink(param_string, "xml");
}




/*
// // OLD API
//
// jQuery.ajax({
// type: "POST",
// url: "/annotator",
// data: params,
// dataType: "json",
// success: function (data) {
// var results = [],
// resultCount = 1,
// ontologies = {},
// terms = {},
// match_types = {},
// matched_ontologies = {},
// matched_terms = {},
// context_map = { "mgrep": "direct", "mapping": "mapping", "closure": "ancestor" };
//
// bp_last_params = data.statistics.parameters;
//
// if (!jQuery.isEmptyObject(data.annotations)) {
// jQuery(data.annotations).each(function () {
// var annotation = this;
// var ontology_name = data.ontologies[annotation.concept.localOntologyId].name;
// var concept_name = annotation.concept.preferredName;
// var context_name = annotation.context.contextName;
// var matched_concept = context_name == "MGREP" ? annotation.concept : annotation.context[CONCEPT_MAP[context_name.toLowerCase()]];
// var matched_ontology_name = data.ontologies[matched_concept.localOntologyId].name;
//
// // Gather sem types for display
// var semantic_types = [];
// jQuery.each(annotation.concept.semantic_types, function () {
// semantic_types.push(this.description);
// });
//
// // Create an array representing the row in the table
// var row = [
// "<a href='/ontologies/" + annotation.concept.localOntologyId + "?p=terms&conceptid=" + encodeURIComponent(annotation.concept.fullId) + "'>" + annotation.concept.preferredName + "</a>",
// "<a href='/ontologies/" + annotation.concept.localOntologyId + "'>" + ontology_name + "</a>",
// context_map[annotation.context.contextName.toLowerCase()],
// semantic_types.join("<br/>"),
// annotation.context.highlight,
// "<a href='/ontologies/" + matched_concept.localOntologyId + "?p=terms&conceptid=" + encodeURIComponent(matched_concept.fullId) + "'>" + matched_concept.preferredName + "</a>",
// "<a href='/ontologies/" + matched_concept.localOntologyId + "'>" + matched_ontology_name + "</a>"
// ];
// results.push(row);
// resultCount++;
// // Keep track of how many results are associated with each ontology
// ontologies[ontology_name] = (ontology_name in ontologies) ? ontologies[ontology_name] + 1 : 1;
//
// // Keep track of how many results are associated with each term
// terms[concept_name.toLowerCase()] = (concept_name.toLowerCase() in terms) ? terms[concept_name.toLowerCase()] + 1 : 1;
//
// // Keep track of match types
// match_types[context_map[annotation.context.contextName.toLowerCase()]] = (context_map[annotation.context.contextName.toLowerCase()] in match_types) ? match_types[context_map[annotation.context.contextName.toLowerCase()]] + 1 : 1;
//
// // Keep track of matched terms
// matched_terms[matched_concept.preferredName.toLowerCase()] = (matched_concept.preferredName.toLowerCase() in matched_terms) ? matched_terms[matched_concept.preferredName.toLowerCase()] + 1 : 1;
//
// // Keep track of matched ontologies
// matched_ontologies[matched_ontology_name] = (matched_ontology_name in matched_ontologies) ? matched_ontologies[matched_ontology_name] + 1 : 1;
// });
// }
//
// // Add result counts
// //var total_count = data.statistics.mgrep + data.statistics.mapping + data.statistics.closure;
// //jQuery("#result_counts").html("total results " + " <span class='result_count'>" + total_count + "</span>&nbsp;&nbsp;&nbsp;&nbsp;(");
// //jQuery("#result_counts").append(context_map["mgrep"] + " <span class='result_count'>" + data.statistics.mgrep + "</span>");
// //jQuery("#result_counts").append("&nbsp;&nbsp;/&nbsp;&nbsp;" + context_map["closure"] + " <span class='result_count'>" + data.statistics.closure + "</span>");
// //jQuery("#result_counts").append("&nbsp;&nbsp;/&nbsp;&nbsp;" + context_map["mapping"] + " <span class='result_count'>" + data.statistics.mapping + "</span>");
// //jQuery("#result_counts").append(")");
//
// // Add checkboxes to filters
// createFilterCheckboxes(ontologies, "filter_ontology_checkboxes", "ontology_filter_list");
// createFilterCheckboxes(terms, "filter_terms_checkboxes", "terms_filter_list");
// createFilterCheckboxes(match_types, "filter_match_type_checkboxes", "match_type_filter_list");
// createFilterCheckboxes(matched_ontologies, "filter_matched_ontology_checkboxes", "matched_ontology_filter_list");
// createFilterCheckboxes(matched_terms, "filter_matched_terms_checkboxes", "matched_terms_filter_list");
//
// // Add links for downloading results
// annotatorPostForm("tabDelimited");
// annotatorPostForm("text");
// annotatorPostForm("xml");
//
// // Reset table
// annotationsTable.fnClearTable();
// annotationsTable.fnSortNeutral();
// removeFilters();
//
// // Generate parameters for list at bottom of page
// generateParameters();
//
// // Need to re-init because we're not using "live" because of propagation issues
// filter_ontologies.init();
// filter_terms.init();
// filter_match_type.init();
// filter_matched_ontologies.init();
// filter_matched_terms.init();
//
// // Add data
// annotationsTable.fnAddData(results);
//
// jQuery("#annotations_container").show(600, jQuery(".annotator_spinner").hide());
// },
// error: handleAnnotatorError
// });
//
// // OLD API
*/


// Creates an HTML form with a button that will POST to the annotator
//function annotatorPostForm(format) {
//  "use strict";
//  // TODO: Check whether 'text' and 'tabDelimited' could work.
//  // For now, assume that json and xml will work or should work.
//  var format_map = { "json": "JSON", "xml": "XML", "text": "Text", "tabDelimited": "CSV" };
//  var params = bp_last_params;
//  params["format"] = format;
//  var form_fields = [];
//  jQuery.each(params, function (k, v) {
//    if (v != null) {
//      form_fields.push("<input type='hidden' name='" + k + "' value='" + v + "'>");
//    }
//  });
//  var action = "action='" + BP_CONFIG.rest_url + "/annotator'";
//  var form = jQuery("<form " + action + " method='post' target='_blank'/>")
//    .append(form_fields.join(""))
//    .append("<input type='submit' value='" + format_map[format] + "'>");
//  jQuery("#download_links_" + format.toLowerCase()).html(form);
//}

