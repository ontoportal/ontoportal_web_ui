
"use strict";

var
  ajax_process_cls_interval = null,
  ajax_process_ont_interval = null,
  ajax_process_timing = 250; // It takes about 250 msec to resolve a class ID to a prefLabel

var ajax_process_halt = function () {
  ajax_process_cls_halt();
  ajax_process_ont_halt();
};
var ajax_process_cls_halt = function () {
  // clear all the classes and ontologies to be resolved by ajax
  jQuery("a.cls4ajax").removeClass('cls4ajax');
  jQuery("a.ajax-modified-cls").removeClass('ajax-modified-cls');
  window.clearInterval(ajax_process_cls_interval); // stop the ajax process
};
var ajax_process_ont_halt = function () {
  // clear all the classes and ontologies to be resolved by ajax
  jQuery("a.ont4ajax").removeClass('ont4ajax');
  jQuery("a.ajax-modified-ont").removeClass('ajax-modified-ont');
  window.clearInterval(ajax_process_ont_interval); // stop the ajax process
};

var ajax_process_ont = function() {
  // Check on whether to stop the ajax process
  if( jQuery("a.ont4ajax").length === 0 ){
    ajax_process_ont_halt();
    return true;
  }
  var linkA = jQuery("a.ont4ajax").first(); // FIFO queue
  if(linkA === undefined){
    return true;
  }
  if(linkA.hasClass('ajax-modified-ont') ){
    return true; // processed this one already.
  }
  linkA.removeClass('ont4ajax'); // processing this one.
  var ontAcronym = linkA.text();
  var ajaxURI = "/ajax/json_ontology/?ontology=" + encodeURIComponent(ontAcronym);
  jQuery.get(ajaxURI, function(data){
    if(typeof data !== "undefined" && data.hasOwnProperty('name')){
      var ont_name = data.name;
      linkA.text(ont_name);
      linkA.addClass('ajax-modified-ont'); // processed this one.
      // find and process any identical ontologies
      jQuery( 'a[href="/ontologies/' + ontAcronym + '"]').each(function(i,e){
        var link = jQuery(this);
        if(! link.hasClass('ajax-modified-ont') ){
          link.removeClass('ont4ajax');   // processing this one.
          link.text(ont_name);
          link.addClass('ajax-modified-ont'); // processed this one.
        }
      });
    }
  });
};

var ajax_process_cls = function() {
  // Check on whether to stop the ajax process
  if( jQuery("a.cls4ajax").length === 0 ){
    ajax_process_cls_halt();
    return true;
  }
  var linkA = jQuery("a.cls4ajax").first(); // FIFO queue
  if(linkA === undefined){
    return true;
  }
  if(linkA.hasClass('ajax-modified-cls') ){
    return true; // processed this one already.
  }
  linkA.removeClass('cls4ajax'); // processing this one.
  var unique_id = linkA.attr('href');
  var ids = unique_id_split(unique_id);
  var cls_id = ids[0];
  var ont_acronym = ids[1];
  var ont_uri = "/ontologies/" + ont_acronym;
  var cls_uri = ont_uri + "?p=classes&conceptid=" + encodeURIComponent(cls_id);
  var ajax_uri = "/ajax/classes/label?ontology=" + ont_acronym + "&concept=" + encodeURIComponent(cls_id);
  jQuery.get(ajax_uri, function(data){
    data = data.trim();
    if (typeof data !== "undefined" && data.length > 0 && data.indexOf("http") !== 0) {
      var cls_name = data;
      linkA.html(cls_name);
      linkA.attr('href', cls_uri);
      linkA.addClass('ajax-modified-cls');
      // find and process any identical classes
      jQuery( 'a[href="' + unique_id + '"]').each(function(i,e){
        var link = jQuery(this);
        if(! link.hasClass('ajax-modified-cls') ){
          link.removeClass('cls4ajax');   // processing this one.
          link.html(cls_name);
          link.attr('href', cls_uri);
          link.addClass('ajax-modified-cls'); // processed this one.
        }
      });
    } else {
      // remove the unique_id separator and the ontology acronym from the href
      linkA.attr('href', cls_id);  // it may not be an ontology class, don't use the cls_uri
      linkA.addClass('ajax-modified-cls');
    }
  });
};

// Note similar code in concepts_helper.rb mirrors the following code:
var unique_split_str = '||||';
function unique_class_id(cls_id, ont_acronym){
  return cls_id + unique_split_str + ont_acronym;
}
function unique_id_split(unique_id){
  return unique_id.split(unique_split_str);
}
function get_link_for_cls_ajax(cls_id, ont_acronym) {
  // ajax call will replace the href and label (triggered by class='cls4ajax')
  return '<a class="cls4ajax" href="' + unique_class_id(cls_id, ont_acronym) + '">' + cls_id + '</a>';
}
function get_link_for_ont_ajax(ont_acronym) {
  return '<a class="ont4ajax" href="/ontologies/' + ont_acronym + '">' + ont_acronym + '</a>';
}

