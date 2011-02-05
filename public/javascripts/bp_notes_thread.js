/**
 * @author palexander
 */

var BP_NOTES_THREAD_LOADED = true;

// Cache object to hold the html for the form
if (typeof cache === 'undefined') {
	var cache = new Object();
}

jQuery(document).ready(function(){
	// Get the cached form for use and prep after clicking 'reply' in a thread
  jQuery(".create_reply").live('click', function() {
		var note_id = jQuery(this).parents(".response").attr('id').substring(5);
		var replyDiv = "#" + jQuery(this).parents(".response").attr('id') + "_reply";
		
		// Hide all reply containers, show all reply links
		jQuery(".reply_form_container").each(function() {
			jQuery(this).html("");
			jQuery(this).parent().hide();
			jQuery(".create_reply_container").show();
		});
		
		// Place HTML from the cache object into the proper spot in the thread
		jQuery(this).parent().hide();
		jQuery("#reply_" + jQuery(this).attr("note_id")).html(cache.reply_form);
		jQuery("#reply_" + jQuery(this).attr("note_id") + " .create_note_container").show();
		jQuery(replyDiv).show();
		
		// Reset values for our position in the thread
		jQuery("#thread_create_comment_appliesTo").val(note_id);
		jQuery("#thread_create_new_term_appliesTo").val(note_id);
		jQuery("#thread_create_change_hierarchy_appliesTo").val(note_id);
		jQuery("#thread_create_change_prop_value_appliesTo").val(note_id);
		jQuery(".thread_note_submit_data").data("prefix", "thread_");
		jQuery(".thread_note_submit_data").data("action", "thread");
		jQuery(".thread_note_submit_data").data("ont_id", jQuery.data(document.body, "ontology_id"));
  });
	
	jQuery(".cancel_reply").live('click', function() {
		jQuery("#" + jQuery(this).attr("note_id") + "_reply_link").show();
		jQuery(this).parent().hide();
	});
	
	jQuery(".response_head").live('click', function() {
		var collapse = "#" + jQuery(this).parent().attr('id') + "_collapse";
		jQuery(collapse).toggle();
		jQuery(this).toggleClass("collapsed");
	});

	// Hide all
	jQuery(".hide_all_responses").live('click', function(){
		var note_id = jQuery(this).parents(".data_div").attr("id");
		jQuery(".collapsible." + note_id).hide();
	});
	
	// Show all
	jQuery(".show_all_responses").live('click', function(){
		var note_id = jQuery(this).parents(".data_div").attr("id");
		jQuery(".collapsible." + note_id).show();
	});
	
	// Wire up the archive buttons
	jQuery(".archive_note").live('click', function(){
	  var form = jQuery(this).closest('form');
	  var note_id = jQuery(form).children("input[name=note_id]").val();
	  var row_id = "row_" + note_id;
	  var ontology_virtual_id = jQuery(form).children("input[name=ontology_id]").val();
    var archived = jQuery(form).children("input[name=archived]").val();
	  var notes_url = "/notes/archive";
	  var archive;
	  var archivethread;
	  
	  archive = (archived == "false") ? "archive" : "unarchive";	  
    archivethread = (archived == "false") ? "archivethread" : "unarchivethread";   
	  
	  // Clear existing error messages
	  jQuery(".error_message").html("");
	  
	  jQuery("#" + note_id + "_archive_spinner").show();
	  
    jQuery.ajax({
      type: "POST",
      url: notes_url,
      data: archive + "=true&" + archivethread + "=true&noteid=" + note_id + "&ontology_virtual_id=" + ontology_virtual_id,
      dataType: "json",
      success: function(data) {
        jQuery("#" + note_id + "_archive_spinner").hide();
        
        if (archived == "false") {
          // Archive
          jQuery("#" + note_id + "_title_archived").html('archived');
          jQuery("#" + note_id + "_row_archived").html('archived');
          jQuery("#" + note_id + "_archive").val('Unarchive Note');
          jQuery("#" + note_id + "_spinner_text").html('Unarchiving');
          jQuery(form).children("input[name=archived]").val("true");
          
          if (oTable !== undefined) {
            jQuery.data(document.body, row_id, jQuery("#row_thread_" + note_id).html());
            oTable.fnUpdate("true", document.getElementById(note_id + "_tr"), 2, false);
          }
        } else {
          // Unarchive
          jQuery("#" + note_id + "_title_archived").html('');
          jQuery("#" + note_id + "_row_archived").html('');
          jQuery("#" + note_id + "_archive").val('Archive Note');
          jQuery("#" + note_id + "_spinner_text").html('Archiving');
          jQuery(form).children("input[name=archived]").val("false");

          if (oTable !== undefined) {
            jQuery.data(document.body, row_id, jQuery("#row_thread_" + note_id).html());
            oTable.fnUpdate("false", document.getElementById(note_id + "_tr"), 2, false);
          }
        }
        
        // Hide or unhide notes
        if (hideOrUnhideArchivedNotes !== undefined) {
          hideOrUnhideArchivedNotes();
        }
      },
      error: function(XMLHttpRequest, textStatus, errorThrown) {
        jQuery("#" + note_id + "_archive_spinner").hide();
        jQuery("#" + note_id + "_archive_note_form").parent().append('<span class="error_message">Problem submitting, please try again</span>');
      }
    });
	});
});

