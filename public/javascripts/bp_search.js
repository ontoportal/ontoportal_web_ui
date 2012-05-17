jQuery(document).ready(function(){
  jQuery("#search_button").button();

  // Put cursor in search box by default
  jQuery("#search_keywords").focus();

  // Show/hide on refresh
  if (jQuery("#search_select_ontologies").is(":checked")) {
    jQuery("#ontology_picker_options").removeClass("not_visible");
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

  // Perform search
  jQuery("#search_button").click(function(event){
    event.preventDefault();

    jQuery("#search_spinner").show();

    var ont_val = jQuery("#ontology_ontologyId").val();

    var onts = (ont_val === null) ? "" : ont_val.join(",");
    var query = jQuery("#search_keywords").val();
    var exactMatch = jQuery("#search_exact_match").is(":checked");
    var includeProps = jQuery("#search_include_props").is(":checked");

    jQuery.ajax({
      url: "/search/json?page_size=99999&ontology_ids="+onts+"&query="+query+"&exact_match="+exactMatch+"&include_props=1",
      dataType: "json",
      async: false,
      success: function(data){
        var results = [];
        var ontologies = {};
        var ontology_links = [];

        if (!jQuery.isEmptyObject(data)) {
          jQuery(data.results).each(function(){
            var additional_results = "";
            var additional_results_link = "";
            var res = this;

            var label_html = normalizeObsoleteTerms(res);

            // Additional terms for this ontology
            if (res.additional_results !== undefined) {
              more_res = res.additional_results;
              additional_results_link = jQuery("<span/>")
                                          .append(jQuery("<span/>")
                                          .addClass("additional_results_link search_result_link")
                                          .html(" - <a href='#additional_results' class='additional_results_link' data-bp_additional_results_for='"+more_res[0].ontologyId+"'>" + more_res.length + " more from this ontology<span class='not_visible hide_link'>[hide]</span></a>")).html();

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

            results.push(row.join(""));
          });
        }

        // Display error message if no results found
        var result_count = jQuery("#result_stats");
        if (data.current_page_results == 0) {
          result_count.html("");
          jQuery("#search_results").html("<h2 style='padding-top: 1em;'>No results found</h2>");
        } else {
          var results_by_ont = jQuery("#ontology_ontologyId").val() === null ? " in " + data.current_page_results + " ontologies" : "";
          result_count.html("Top " + data.disaggregated_current_page_results + " results" + results_by_ont);
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
  // Get the top level stuff first
  jQuery("#search_results .def_container .ajax_def").each(function(){
    var def = jQuery(this);
    jQuery.getJSON("/ajax/json_term?conceptid="+def.attr("data-bp_conceptid")+"&ontologyid="+def.attr("data-bp_ontologyid"),
      function(data){
        if (data !== null && data.definitions !== undefined && data.definitions !== null) {
          def.html(data.definitions);
        } else {
          def.parent().html("");
        }
      }
    );
  });

  // Now get the additional that are hidden
  jQuery("#search_results .additional_def_container .ajax_def").each(function(){
    var def = jQuery(this);
    jQuery.getJSON("/ajax/json_term?conceptid="+def.attr("data-bp_conceptid")+"&ontologyid="+def.attr("data-bp_ontologyid"),
      function(data){
        if (data !== null && data.definitions !== undefined && data.definitions !== null) {
          def.html(data.definitions);
        } else {
          def.parent().html("");
        }
      }
    );
  });
}

function termHTML(res, label_html, displayOntologyName) {
  var ontologyName = displayOntologyName ? " - " + res.ontologyDisplayLabel : "";
  return "<div class='term_link'><a title='"+res.preferredName+"' href='/ontologies/"+res.ontologyId+"?p=terms&conceptid="+encodeURIComponent(res.conceptId)+"'>"+jQuery(label_html).html()+ontologyName+"</a></div>";
}

function resultLinksHTML(res) {
  return "<span class='additional'><a href='/ajax/term_details/"+res.ontologyId+"?styled=false&conceptid="+encodeURIComponent(res.conceptId)+"' class='term_details search_result_link' rel='facebox[.term_details_pop]'>details</a> - <a href='javascript:void(0);' data-bp_ontologyid='"+res.ontologyId+"' data-bp_conceptid='"+encodeURIComponent(res.conceptId)+"' class='term_visualize search_result_link'>visualize</a></span>";
}

function definitionHTML(res, defClass) {
  defClass = defClass === undefined ? "def_container" : defClass;
  return "<div class='"+defClass+"'><span class='ajax_def' data-bp_conceptid='"+encodeURIComponent(res.conceptId)+"' data-bp_ontologyid='"+res.ontologyId+"'><em>loading...</em></span></div>";
}