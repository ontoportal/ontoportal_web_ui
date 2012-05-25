jQuery(document).ready(function(){
  // Wire advanced search categories
  jQuery("#search_categories").chosen();

  jQuery("#search_button").button();

  // Put cursor in search box by default
  jQuery("#search_keywords").focus();

  // Show/hide on refresh
  if (advancedOptionsSelected()) {
    jQuery("#search_options").removeClass("not_visible");
  }

  jQuery("#search_select_ontologies").change(function(){
    if (jQuery(this).is(":checked")) {
      jQuery("#ontology_picker_options").removeClass("not_visible");
    } else {
      jQuery("#ontology_picker_options").addClass("not_visible");
      jQuery("#ontology_ontologyId").val("");
      jQuery("#ontology_ontologyId").trigger("liszt:updated");
    }
  });

  jQuery("#search_results a.additional_results_link").live("click", function(event){
    event.preventDefault();
    jQuery("#additional_results_"+jQuery(this).attr("data-bp_additional_results_for")).toggleClass("not_visible");
    jQuery(this).children(".hide_link").toggleClass("not_visible");
    jQuery(this).toggleClass("not_underlined");
  });

  // Show advanced options
  jQuery("#advanced_options").click(function(event){
    jQuery("#search_options").toggleClass("not_visible");
    jQuery("#hide_advanced_options").toggleClass("not_visible");
  });

  // Perform search
  jQuery("#search_button").click(function(event){
    event.preventDefault();

    jQuery("#search_spinner").show();

    var ont_val = jQuery("#ontology_ontologyId").val();

    var onts = (ont_val === null) ? "" : ont_val.join(",");
    var query = jQuery("#search_keywords").val();

    // Advanced options
    var includeProps = jQuery("#search_include_props").is(":checked");
    var includeViews = jQuery("#search_include_views").is(":checked");
    var includeObsolete = jQuery("#search_include_obsolete").is(":checked");
    var includeOnlyDefinitions = jQuery("#search_only_definitions").is(":checked");
    var exactMatch = jQuery("#search_exact_match").is(":checked");
    var categories = jQuery("#search_categories").val() || "";

    jQuery.ajax({
      url: "/search/json",
      data: {
        query: query,
        ontology_ids: onts,
        exact_match: exactMatch,
        include_props: includeProps,
        include_views: includeViews,
        include_obsolete: includeObsolete,
        only_definitions: includeOnlyDefinitions,
        categories: categories
      },
      dataType: "json",
      async: false,
      success: function(data){
        var results = [];
        var ontologies = {};
        var ontology_links = [];

        if (!jQuery.isEmptyObject(data)) {
          jQuery(data.results).each(function(){
            results.push(processSearchResult(this).join(""));
          });
        }

        // Obsolete terms should appear at the end with a heading
        if (data.obsolete_results.length > 0) {
          results.push("<h2 style='font-size: 150%;'>Obsolete Terms</h2>");
          jQuery(data.obsolete_results).each(function(){
            results.push(processSearchResult(this).join(""));
          });
        }

        // Display error message if no results found
        var result_count = jQuery("#result_stats");
        if (data.current_page_results == 0) {
          result_count.html("");
          jQuery("#search_results").html("<h2 style='padding-top: 1em;'>No results found</h2>");
        } else {
          var results_by_ont = jQuery("#ontology_ontologyId").val() === null ? " in <span id='ontologies_count_total'>" + data.current_page_results + "</span> ontologies" : "";
          result_count.html("Top <span id='result_count_total'>" + data.disaggregated_current_page_results + "</span> results" + results_by_ont);
          jQuery("#search_results").html(results.join(""));
        }

        jQuery("a[rel*=facebox]").facebox();
        jQuery("#search_results").show();
      }
    });

    getAllDefinitions();
    jQuery("#search_spinner").hide();
  });

  // Search on enter
  jQuery("#search_keywords").bind("keyup", function(event){
    if (event.which == 13) {
      jQuery("#search_button").click();
    }
  });

  // Details/visualze link to show details pane and visualize flexviz
  jQuery.facebox.settings.closeImage = '/javascripts/JqueryPlugins/facebox/closelabel.png';
  jQuery.facebox.settings.loadingImage = '/javascripts/JqueryPlugins/facebox/loading.gif';

  // Position of popup for details
  jQuery(document).bind('reveal.facebox', function(){
    if (jQuery("div.term_details_pop").is(":visible")) {
      jQuery("div.term_details_pop").css("max-height", jQuery(window).height() - jQuery("div.term_details_pop").offset().top * 2 + "px");
    }
  });

  // Use pop-up with flex via an iframe for "visualize" link
  jQuery("a.term_visualize").live("click", (function(){
    var ontologyid = jQuery(this).attr("data-bp_ontologyid");
    var conceptid = jQuery(this).attr("data-bp_conceptid");

    jQuery("#flexviz").html('<iframe src="/flexviz/'+ontologyid+'?conceptid='+conceptid+'" frameborder=0 height="500px" width="500px" scrolling="no"></iframe>').show();
    jQuery.facebox({ div: '#flexviz' });
  }));

  // Check for existing parameters/queries and update UI accordingly
  var params = jQuery.QueryString;
  if ("q" in params || "query" in params) {
    var query = ("q" in params) ? params["q"] : params["query"];
    jQuery("#search_keywords").val(query);

    if (params["exactmatch"] == "true") {
      jQuery("#search_exact_match").click();
    }

    if (params["searchproperties"] == "true") {
      jQuery("#search_include_props").click();
    }

    if ("ontologyids" in params) {
      var ontologyIds = params["ontologyids"].split(",");
      jQuery("#search_select_ontologies").attr("checked", false)
      jQuery("#ontology_ontologyId").val(ontologyIds);
      jQuery("#ontology_ontologyId").trigger("liszt:updated");
      jQuery("#search_select_ontologies").click().change();
    }

    jQuery("#search_button").click();
  } else if (jQuery("#search_keywords").val() != "") {
    jQuery("#search_button").click();
  }
});

function processSearchResult(res) {
  var additional_results = "";
  var additional_results_link = "";

  var label_html = normalizeObsoleteTerms(res);

  // Additional terms for this ontology
  if (typeof res.additional_results !== "undefined" && res.additional_results.length > 0 ||
      typeof res.additional_results_obsolete !== "undefined" && res.additional_results_obsolete.length > 0) {
    var more_res = res.additional_results;
    var additional_results_obsolete_count = typeof res.additional_results_obsolete !== "undefined" ? res.additional_results_obsolete.length : 0
    additional_results_link = jQuery("<span/>")
                                .append(jQuery("<span/>")
                                .addClass("additional_results_link search_result_link")
                                .html(" - <a href='#additional_results' class='additional_results_link' data-bp_additional_results_for='"+more_res[0].ontologyId+"'>" + (more_res.length + additional_results_obsolete_count) + " more from this ontology<span class='not_visible hide_link'>[hide]</span></a>")).html();

    var additional_rows = [];
    jQuery(more_res).each(function(){
      additional_rows.push([
        "<div class='search_result_additional'>",
        termHTML(this, normalizeObsoleteTerms(this), false),
        definitionHTML(this, "additional_def_container"),
        "<div class='search_result_links'>"+resultLinksHTML(this)+"</div>",
        "</div>"
      ].join(""));
    });

    // Obsolete terms should appear at the end with a heading
    if (typeof res.additional_results_obsolete !== "undefined" && res.additional_results_obsolete.length > 0) {
      additional_rows.push("<h2 style='font-size: 120%; padding-left: 20px;'>Obsolete Terms</h2>");
      jQuery(res.additional_results_obsolete).each(function(){
        additional_rows.push([
          "<div class='search_result_additional'>",
          termHTML(this, normalizeObsoleteTerms(this), false),
          definitionHTML(this, "additional_def_container"),
          "<div class='search_result_links'>"+resultLinksHTML(this)+"</div>",
          "</div>"
        ].join(""));
      });
    }

    additional_results = jQuery("<div/>")
                                .append(jQuery("<div/>")
                                .attr("id", "additional_results_"+more_res[0].ontologyId)
                                .addClass("additional_results")
                                .addClass("not_visible")
                                .html(additional_rows.join("")))
                              .html();

  }

  // Don't include ontology name if searching a single ontology
  var display_ont_name = (jQuery("#ontology_ontologyId").val() === null || jQuery("#ontology_ontologyId").val().length > 1)

  var row = [
    "<div class='search_result'>",
    termHTML(res, label_html, display_ont_name),
    definitionHTML(res),
    "<div class='search_result_links'>"+resultLinksHTML(res) + additional_results_link+"</div>",
    additional_results,
    "</div>"
  ];

  return row;
}

function normalizeObsoleteTerms(res) {
  // We have to look for a span here, indicating that the term is obsolete.
  // If not, add the term to a new span to match obsolete structure so we can process them the same.
  var max_word_length = 60;
  var elipses = (res.preferredName.length > max_word_length) ? "..." : "";
  var label_html = (res.isObsolete == "1") ? jQuery(res.label_html) : jQuery("<span/>").append(res.label_html);
  label_html = jQuery("<span/>").append(label_html.html(label_html.html().substring(0, max_word_length)+elipses));
  return label_html;
}

function getAllDefinitions() {
  var keepOnlyDefinitions = jQuery("#search_only_definitions").is(":checked");

  // Notice for filtering search results without definitions
  if (keepOnlyDefinitions) {
    jQuery("#search_messages").html("removing terms without definitions...");
  }

  // Get the top level stuff first
  var count = 0;
  var totalSearchResults = currentResultsCount();
  jQuery("#search_results .def_container .ajax_def").each(function(){
    var def = jQuery(this);
    getDefinition(def, keepOnlyDefinitions, count, totalSearchResults);

    count += 1;
    if (count == totalSearchResults) {
      if (keepOnlyDefinitions) {
        jQuery("#search_messages").html("");
      }
    }
  });

  // Now get the additional that are hidden
  jQuery("#search_results .additional_def_container .ajax_def").each(function(){
    var def = jQuery(this);
    count += 1;
    getDefinition(def, keepOnlyDefinitions, count, totalSearchResults);
  });
}

function getDefinition(def, keepOnlyDefinitions, count, totalSearchResults) {
  jQuery.ajax({
    url: "/ajax/json_term?conceptid="+def.attr("data-bp_conceptid")+"&ontologyid="+def.attr("data-bp_ontologyid"),
    dataType: 'json',
    success: function(data){
      showDefinition(data, def, keepOnlyDefinitions);
      if (count == totalSearchResults) {
        if (keepOnlyDefinitions) {
          jQuery("#search_messages").html("");
        }
      }
    },
    error: function(){
      // Failed to retreive definition
      if (keepOnlyDefinitions) {
        // Remove entire term
        def.parent().parent().html("");
      } else {
        // Remove loading text
        def.parent().html("");
      }

      if (count == totalSearchResults) {
        if (keepOnlyDefinitions) {
          jQuery("#search_messages").html("");
        }
      }
    }
  });
}

function showDefinition(data, def, keepOnlyDefinitions) {
  var defLimit = 235;

  if (typeof keepOnlyDefinitions === "undefined" || keepOnlyDefinitions == null) {
    keepOnlyDefinitions = false;
  }

  if (data !== null && typeof data.definitions !== "undefined" && data.definitions !== null && data.definitions.length != 0) {
    if (data.definitions.length > defLimit) {
      var defs = data.definitions.slice(0, defLimit).split(" ");
      // Remove the last word in case we got one partway through
      defs.pop();
      def.html(defs.join(" ")+" ...");
    } else {
      def.html(data.definitions)
    }
  } else {
    if (keepOnlyDefinitions) {
      // Remove entire term
      def.parent().parent().remove();
    } else {
      // Remove loading text
      def.parent().html("");
    }
  }

  // Update count
  jQuery("#result_count_total").html(currentResultsCount());
  jQuery("#ontologies_count_total").html(currentOntologiesCount());
}

function advancedOptionsSelected() {
  var check = [
    function(){return jQuery("#search_include_props").is(":checked");},
    function(){return jQuery("#search_include_views").is(":checked");},
    function(){return jQuery("#search_include_obsolete").is(":checked");},
    function(){return jQuery("#search_only_definitions").is(":checked");},
    function(){return jQuery("#search_exact_match").is(":checked");},
    function(){return jQuery("#search_categories").val() !== null && jQuery("#search_categories").val().length > 0;},
    function(){return jQuery("#ontology_ontologyId").val() !== null && jQuery("#ontology_ontologyId").val().length > 0;},
  ];

  var length = check.length;
  for (var i = 0; i < length; i++) {
    var selected = check[i]();
    if (selected)
      return true;
  }

  return false;
}

function currentResultsCount() {
  return jQuery(".search_result").length + jQuery(".search_result_additional").length;
}

function currentOntologiesCount() {
  return jQuery(".search_result").length;
}

function termHTML(res, label_html, displayOntologyName) {
  var ontologyName = displayOntologyName ? " - " + res.ontologyDisplayLabel : "";
  return "<div class='term_link'><a title='"+res.preferredName+"' href='/ontologies/"+res.ontologyId+"?p=terms&conceptid="+encodeURIComponent(res.conceptId)+"'>"+jQuery(label_html).html()+ontologyName+"</a></div>";
}

function resultLinksHTML(res) {
  return "<span class='additional'><a href='/ajax/term_details/"+res.ontologyId+"?styled=false&conceptid="+encodeURIComponent(res.conceptId)+"' class='term_details search_result_link' rel='facebox[.term_details_pop]'>details</a> - <a href='javascript:void(0);' data-bp_ontologyid='"+res.ontologyId+"' data-bp_conceptid='"+encodeURIComponent(res.conceptId)+"' class='term_visualize search_result_link'>visualize</a></span>";
}

function definitionHTML(res, defClass) {
  defClass = typeof defClass === "undefined" ? "def_container" : defClass;
  return "<div class='"+defClass+"'><span class='ajax_def' data-bp_conceptid='"+encodeURIComponent(res.conceptId)+"' data-bp_ontologyid='"+res.ontologyId+"'><em>loading...</em></span></div>";
}