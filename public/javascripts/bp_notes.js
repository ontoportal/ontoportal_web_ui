/**
 * @author palexander
 */

var BP_NOTES_LOADED = true;

jQuery(document).ready(function(){
	jQuery(window).bind('hashchange', function() {
		var hash = window.location.hash || '#details';
		/**
		tabContainers.hide();
		tabContainers.filter(hash).show();
		jQuery('div.tabs ul.tabNavigation a').removeClass('selected');
		jQuery('a[hash=' + hash + ']').addClass('selected');
		**/
	});
	
	jQuery(".create_note_submit").live('click', function() {
		var note_type = jQuery(this).attr("note_type");
		var prefix = jQuery(this).data("prefix") == null ? "" : jQuery(this).data("prefix");
		var action = jQuery(this).data("action");
		var ONT = jQuery(this).data("ont_id");
		var NOTES_URL = "/notes/";

		// Disable button, activate spinner and text
		var button = this;
		button_loading(button, prefix);
		
		switch (note_type) {
		case "create_comment":
			var note = new Comment(prefix, ONT);
			note.validate();
			break;
		case "create_new_term":
			var note = new ProposalForCreateEntity(prefix, ONT);
			note.validate();
			break;
		case "create_change_hierarchy":
			var note = new ProposalForChangeHierarchy(prefix, ONT);
			note.validate();
			break;
		case "create_change_prop_value":
			var note = new ProposalForChangePropertyValue(prefix, ONT);
			note.validate();
		}
		
		jQuery.ajax({
				type: "POST",
				url: NOTES_URL,
				data: note.member_variables,
				dataType: "json",
				success: function(data) {
					button_reset(button);
					
					// What do we do with the returned data?
					if (action == "thread_root") {
						jQuery.get("/notes/ajax/single/" + data.ontologyId + "?noteid=" + data.id,
								function(html) {
									// Show the response container
									jQuery("#responses_container").show();
									jQuery("#responses_container").append(html);
								}
						);
					} else if (action == "thread") {
						jQuery.get("/notes/ajax/single/" + data.ontologyId + "?noteid=" + data.id,
								function(html) {
									jQuery("#" + data.appliesTo.id + "_children").append(html);
									
									// Hide all reply containers, show all reply links
									jQuery(".reply_form_container").each(function() {
										jQuery(this).html("");
										jQuery(this).parent().hide();
										jQuery(".create_reply_container").show();
									});
								}
						);
					} else {
						// Get JSON response for new row and add if successful
						jQuery.get("/notes/ajax/single_list/" + data.ontologyId + "?noteid=" + data.id,
								function(json) {
									// Check for "No notes" message and delete
									var no_notes_check = document.getElementById("no_notes");
									if (no_notes_check != null) {
										oTable.fnDeleteRow(oTable.fnGetPosition(document.getElementById("no_notes")));
									}
									
									// We add the (+ "") statement to "cast" to a string
									oTable.fnAddData([
						                    json.subject + "",
						                    json.author + "",
						                    json.type + "",
						                	json.appliesTo + "",
						                	json.created + ""
					                ]);
								}
						);
					}
					
					note.reset();
					
					// update note_count
					
					//   window.scrollTo(0,$("#"+id).offset().top);
					
				},
				error: function(XMLHttpRequest, textStatus, errorThrown) {
					button_reset(button);
					jQuery("#" + jQuery(button).attr("id") + "_submit_container").append(' <span class="error_message">Problem submitting, please try again</span>');
				}
		});
	});
	
});

function Comment(prefix, ONT) {
	this.form_fields = {
		subject: jQuery("#" + prefix + "create_comment_subject"),
		body: jQuery("#" + prefix + "create_comment_body")
	}

	// Hack so we can use a generic method to validate
	this.member_variables = {
		ontology_virtual_id: ONT,
		appliesTo: jQuery("#" + prefix + "create_comment_appliesTo").val(),
		appliesToType: jQuery("#" + prefix + "create_comment_appliesToType").val(),
		type: jQuery("#" + prefix + "create_comment_noteType").val(),
		author: jQuery("#" + prefix + "create_comment_author").val(),
		subject: jQuery("#" + prefix + "create_comment_subject").val(),
		body: jQuery("#" + prefix + "create_comment_body").val()
	}
	
	this.validate = function() {
		
	}
	
	this.reset = function() {
		for (field in this.form_fields) {
			this.form_fields[field].val("");
		}
	}
}

function ProposalForCreateEntity(prefix, ONT) {
	this.form_fields = {
			subject: jQuery("#" + prefix + "create_new_term_subject"),
			body: jQuery("#" + prefix + "create_new_term_body"),
			reasonForChange: jQuery("#" + prefix + "create_new_term_reasonForChange"),
			contactInfo: jQuery("#" + prefix + "create_new_term_contactInfo"),
			termDefinition: jQuery("#" + prefix + "termDefinition"),
			termId: jQuery("#" + prefix + "termId"),
			termParent: jQuery("#" + prefix + "termParent"),
			termPreferredName: jQuery("#" + prefix + "termPreferredName"),
			termSynonyms: jQuery("#" + prefix + "termSynonyms")
	}

	// Hack so we can use a generic method to validate
	this.member_variables = {
		ontology_virtual_id: ONT,
		appliesTo: jQuery("#" + prefix + "create_new_term_appliesTo").val(),
		appliesToType: jQuery("#" + prefix + "create_new_term_appliesToType").val(),
		type: jQuery("#" + prefix + "create_new_term_noteType").val(),
		author: jQuery("#" + prefix + "create_new_term_author").val(),
		subject: jQuery("#" + prefix + "create_new_term_subject").val(),
		body: jQuery("#" + prefix + "create_new_term_body").val(),
		reasonForChange: jQuery("#" + prefix + "create_new_term_reasonForChange").val(),
		contactInfo: jQuery("#" + prefix + "create_new_term_contactInfo").val(),
		termDefinition: jQuery("#" + prefix + "termDefinition").val(),
		termId: jQuery("#" + prefix + "termId").val(),
		termParent: jQuery("#" + prefix + "termParent").val(),
		termPreferredName: jQuery("#" + prefix + "termPreferredName").val(),
		termSynonyms: jQuery("#" + prefix + "termSynonyms").val()
	}
	
	this.validate = function() {
		
	}
	
	this.reset = function() {
		for (field in this.form_fields) {
			this.form_fields[field].val("");
		}
	}
}

function ProposalForChangeHierarchy(prefix, ONT) {
	this.form_fields = {
			subject: jQuery("#" + prefix + "create_change_hierarchy_subject"),
			body: jQuery("#" + prefix + "create_change_hierarchy_body"),
			reasonForChange: jQuery("#" + prefix + "create_change_hierarchy_reasonForChange"),
			contactInfo: jQuery("#" + prefix + "create_change_hierarchy_contactInfo"),
			oldRelationshipTarget: jQuery("#" + prefix + "oldRelationshipTarget"),
			relationshipTarget: jQuery("#" + prefix + "relationshipTarget"),
			relationshipType: jQuery("#" + prefix + "relationshipType")
	}

	// Hack so we can use a generic method to validate
	this.member_variables = {
		ontology_virtual_id: ONT,
		appliesTo: jQuery("#" + prefix + "create_change_hierarchy_appliesTo").val(),
		appliesToType: jQuery("#" + prefix + "create_change_hierarchy_appliesToType").val(),
		type: jQuery("#" + prefix + "create_change_hierarchy_noteType").val(),
		author: jQuery("#" + prefix + "create_change_hierarchy_author").val(),
		subject: jQuery("#" + prefix + "create_change_hierarchy_subject").val(),
		body: jQuery("#" + prefix + "create_change_hierarchy_body").val(),
		reasonForChange: jQuery("#" + prefix + "create_change_hierarchy_reasonForChange").val(),
		contactInfo: jQuery("#" + prefix + "create_change_hierarchy_contactInfo").val(),
		oldRelationshipTarget: jQuery("#" + prefix + "oldRelationshipTarget").val(),
		relationshipTarget: jQuery("#" + prefix + "relationshipTarget").val(),
		relationshipType: jQuery("#" + prefix + "relationshipType").val()
	}
	
	this.validate = function() {
		
	}
	
	this.reset = function() {
		for (field in this.form_fields) {
			this.form_fields[field].val("");
		}
	}
}

function ProposalForChangePropertyValue(prefix, ONT) {
	this.form_fields = {
			subject: jQuery("#" + prefix + "create_change_prop_value_subject"),
			body: jQuery("#" + prefix + "create_change_prop_value_body"),
			reasonForChange: jQuery("#" + prefix + "create_change_prop_value_reasonForChange"),
			contactInfo: jQuery("#" + prefix + "create_change_prop_value_contactInfo"),
			propertyId: jQuery("#" + prefix + "propertyId"),
			newPropertyValue: jQuery("#" + prefix + "newPropertyValue"),
			oldPropertyValue: jQuery("#" + prefix + "oldPropertyValue")
	}

	// Hack so we can use a generic method to validate
	this.member_variables = {
		ontology_virtual_id: ONT,
		appliesTo: jQuery("#" + prefix + "create_change_prop_value_appliesTo").val(),
		appliesToType: jQuery("#" + prefix + "create_change_prop_value_appliesToType").val(),
		type: jQuery("#" + prefix + "create_change_prop_value_noteType").val(),
		author: jQuery("#" + prefix + "create_change_prop_value_author").val(),
		subject: jQuery("#" + prefix + "create_change_prop_value_subject").val(),
		body: jQuery("#" + prefix + "create_change_prop_value_body").val(),
		reasonForChange: jQuery("#" + prefix + "create_change_prop_value_reasonForChange").val(),
		contactInfo: jQuery("#" + prefix + "create_change_prop_value_contactInfo").val(),
		propertyId: jQuery("#" + prefix + "propertyId").val(),
		newPropertyValue: jQuery("#" + prefix + "newPropertyValue").val(),
		oldPropertyValue: jQuery("#" + prefix + "oldPropertyValue").val()
	}
	
	this.validate = function() {
		
	}
	
	this.reset = function() {
		for (field in this.form_fields) {
			this.form_fields[field].val("");
		}
	}
}

function button_loading(button, prefix) {
	jQuery(".error_message").remove();
	jQuery(button).css("background", "grey").css("color", "darkGrey").css("border", "1px solid darkGrey");
	jQuery(button).attr("disabled", "true");
	jQuery("#" + jQuery(button).attr("id") + "_submit_container").append(' <span class="ajax_message"><img src="/images/spinners/spinner_E2EBF0.gif" style="vertical-align: middle;"> loading...</span>');
}

function button_reset(button) {
	jQuery(button).css("background", "").css("color", "").css("border", "");
	jQuery(button).removeAttr("disabled");
	jQuery(".ajax_message").remove();
}