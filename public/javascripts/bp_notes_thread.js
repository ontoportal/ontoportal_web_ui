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
		jQuery(collapse).slideToggle();
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
});

