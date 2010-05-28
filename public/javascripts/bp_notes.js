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
	
	// Wire up the tabs in the 'Add Note' form box
	jQuery(jQuery.data(document.body, "prefix")).live("click", function(){
		var prefix = jQuery.data(document.body, "prefix");
		var spanId = jQuery(this).attr("id");
		var noteTypeId = jQuery(this).attr("note_type");
		jQuery('.' + prefix + 'note_options_action').hide();
		jQuery('#' + noteTypeId).show();
		jQuery('.' + prefix + 'note_action').removeClass("create_note_selected");
		jQuery(this).addClass("create_note_selected");
	});
	
	// Wire up the "Add Reply" link
	jQuery('.add_reply_button').live("click", function(){
		if (jQuery(this).parent().children(".create_note_container").is(':visible')) {
			jQuery(this).text(jQuery.data(document.body, "add_text"));
			jQuery(this).parent().children(".create_note_container").hide();
		} else {
			jQuery(this).text("Hide " + jQuery.data(document.body, "add_text"));
			jQuery(this).parent().children(".create_note_container").show();
		}
	});
	
	jQuery(".create_note_submit").live('click', function(event) {
		event.preventDefault();
		
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
		
		console.log(note.failedValidation == true);
		
		if (note.failedValidation == true) {
			button_reset(button);
			jQuery("#" + jQuery(button).attr("id") + "_submit_container").append(' <span class="error_message">Invalid entries, please fix and try again</span>');
		} else {
		
			jQuery.ajax({
					type: "POST",
					url: NOTES_URL,
					data: note.member_variables,
					dataType: "json",
					success: function(data) {
						button_reset(button);
						
						// What do we do with the returned data?
						if (action == "root") {
							jQuery.get("/notes/ajax/single/" + data.ontologyId + "?noteid=" + data.id,
									function(html) {
										// Show the response container
										jQuery("#" + data.appliesTo.id + "_responses_container").show();
										jQuery("#" + data.appliesTo.id + "_responses_container").append(html);
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
							                    json.subject_link + "",
							                    json.subject + "",
							                    json.author + "",
							                    json.type + "",
							                	json.appliesTo + "",
							                	json.created + ""
						                ]);
										
										// Redraw table, including sort and filter options
										oTable.fnFilter("");
										jQuery("#notes_list_filter input").val("");
									}
							);
						}
						
						// Reset form fields
						note.reset();
						
						// Update note_count
						var new_note_count = parseInt(jQuery("#note_count").text()) + 1;
						jQuery("#note_count").text(new_note_count);
						// Update the count for this concept in the cache (silently fails if we're not at a concept)
						if (getCache(jQuery.data(document.body, "node_id")) != null) {
							getCache(jQuery.data(document.body, "node_id"))[5] = new_note_count;
						}
						
						// Move window to new note location (TODO: Possible future implementation)
						//   window.scrollTo(0,$("#"+id).offset().top);
					},
					error: function(XMLHttpRequest, textStatus, errorThrown) {
						button_reset(button);
						jQuery("#" + jQuery(button).attr("id") + "_submit_container").append(' <span class="error_message">Problem submitting, please try again</span>');
					}
			});
		}
		
		return false;
	});
	
});

function Comment(prefix, ONT) {
	this.form_fields = {
		subject: { element: jQuery("#" + prefix + "create_comment_subject"),
			errorMessage: "Please enter a subject",
			errorLocation: jQuery("#" + prefix + "create_comment_subject").attr("id") + "_error"
		},
		body: { element: jQuery("#" + prefix + "create_comment_body"),
			errorMessage: "Please enter a message in the body",
			errorLocation: jQuery("#" + prefix + "create_comment_body").attr("id") + "_error"
		}
	}
	
	this.required = [ "subject", "body" ];
	
	this.failedValidation;
	
	// Contains the values that we want to submit
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
		for (field in this.form_fields) {
			if (jQuery.inArray(field, this.required) >= 0 && this.form_fields[field].element.val() === "") {
				this.failedValidation = true;
				jQuery("#" + this.form_fields[field].errorLocation).html("<br/>" + this.form_fields[field].errorMessage);
			} else {
				jQuery("#" + this.form_fields[field].errorLocation).html("");
			}
		}
	}
	
	this.reset = function() {
		for (field in this.form_fields) {
			this.form_fields[field].element.val("");
			jQuery("#" + this.form_fields[field].errorLocation).html("");
		}
	}
}

function ProposalForCreateEntity(prefix, ONT) {
	this.form_fields = {
		reasonForChange: { element: jQuery("#" + prefix + "create_new_term_reasonForChange"),
			errorMessage: "Please enter the rationale for this proposal",
			errorLocation: jQuery("#" + prefix + "create_new_term_reasonForChange").attr("id") + "_error"
		},
		contactInfo: { element: jQuery("#" + prefix + "create_new_term_contactInfo") },
		termDefinition: { element: jQuery("#" + prefix + "termDefinition"),
			errorMessage: "Please enter a definition",
			errorLocation: jQuery("#" + prefix + "termDefinition").attr("id") + "_error" 
		},
		termId: { element: jQuery("#" + prefix + "termId") },
		termParent: { element: jQuery("#" + prefix + "termParent"),
			errorMessage: "Please select a parent term",
			errorLocation: jQuery("#" + prefix + "termParent").attr("id") + "_error"
		},
		termPreferredName: { element: jQuery("#" + prefix + "termPreferredName"),
			errorMessage: "Please enter a preferred name",
			errorLocation: jQuery("#" + prefix + "termPreferredName").attr("id") + "_error"
		},
		termSynonyms: { element: jQuery("#" + prefix + "termSynonyms") }
	}

	this.required = [ "reasonForChange", "termDefinition", "termParent", "termPreferredName" ];
	
	this.failedValidation;
	
	// Contains the values that we want to submit
	this.member_variables = {
		ontology_virtual_id: ONT,
		appliesTo: jQuery("#" + prefix + "create_new_term_appliesTo").val(),
		appliesToType: jQuery("#" + prefix + "create_new_term_appliesToType").val(),
		type: jQuery("#" + prefix + "create_new_term_noteType").val(),
		author: jQuery("#" + prefix + "create_new_term_author").val(),
		subject: getNoteTypeText(jQuery("#" + prefix + "create_new_term_noteType").val()) + ": " + jQuery("#" + prefix + "termPreferredName").val(), // Special text plus preferred name
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
		for (field in this.form_fields) {
			if (jQuery.inArray(field, this.required) >= 0 && this.form_fields[field].element.val() === "") {
				this.failedValidation = true;
				jQuery("#" + this.form_fields[field].errorLocation).html("<br/>" + this.form_fields[field].errorMessage);
			} else {
				jQuery("#" + this.form_fields[field].errorLocation).html("");
			}
		}
	}
	
	this.reset = function() {
		for (field in this.form_fields) {
			this.form_fields[field].element.val("");
			jQuery("#" + this.form_fields[field].errorLocation).html("");
		}
	}
}

function ProposalForChangeHierarchy(prefix, ONT) {
	this.form_fields = {
		reasonForChange: { element: jQuery("#" + prefix + "create_change_hierarchy_reasonForChange"),
			errorMessage: "Please enter the rationale for this proposal",
			errorLocation: jQuery("#" + prefix + "create_change_hierarchy_reasonForChange").attr("id") + "_error"
		},
		contactInfo: { element: jQuery("#" + prefix + "create_change_hierarchy_contactInfo") },
		oldRelationshipTarget: { element: jQuery("#" + prefix + "oldRelationshipTarget") },
		relationshipTarget: { element: jQuery("#" + prefix + "relationshipTarget"),
			errorMessage: "Please enter the target term for this relationship",
			errorLocation: jQuery("#" + prefix + "relationshipTarget").attr("id") + "_error"
		},
		relationshipType: { element: jQuery("#" + prefix + "relationshipType"),
			errorMessage: "Please enter the relationship type",
			errorLocation: jQuery("#" + prefix + "relationshipType").attr("id") + "_error"
		}
	}

	this.required = [ "reasonForChange", "relationshipTarget", "relationshipType" ];
	
	this.failedValidation;
	
	// Contains the values that we want to submit
	this.member_variables = {
		ontology_virtual_id: ONT,
		appliesTo: jQuery("#" + prefix + "create_change_hierarchy_appliesTo").val(),
		appliesToType: jQuery("#" + prefix + "create_change_hierarchy_appliesToType").val(),
		type: jQuery("#" + prefix + "create_change_hierarchy_noteType").val(),
		author: jQuery("#" + prefix + "create_change_hierarchy_author").val(),
		subject: getNoteTypeText(jQuery("#" + prefix + "create_change_hierarchy_noteType").val()) + ": "
			+ jQuery("#" + prefix + "relationshipType").val(), // Special text plus preferred name
		body: jQuery("#" + prefix + "create_change_hierarchy_body").val(),
		reasonForChange: jQuery("#" + prefix + "create_change_hierarchy_reasonForChange").val(),
		contactInfo: jQuery("#" + prefix + "create_change_hierarchy_contactInfo").val(),
		oldRelationshipTarget: jQuery("#" + prefix + "oldRelationshipTarget").val(),
		relationshipTarget: jQuery("#" + prefix + "relationshipTarget").val(),
		relationshipType: jQuery("#" + prefix + "relationshipType").val()
	}
	
	this.validate = function() {
		for (field in this.form_fields) {
			if (jQuery.inArray(field, this.required) >= 0 && this.form_fields[field].element.val() === "") {
				this.failedValidation = true;
				jQuery("#" + this.form_fields[field].errorLocation).html("<br/>" + this.form_fields[field].errorMessage);
			} else {
				jQuery("#" + this.form_fields[field].errorLocation).html("");
			}
		}
	}
	
	this.reset = function() {
		for (field in this.form_fields) {
			this.form_fields[field].element.val("");
			jQuery("#" + this.form_fields[field].errorLocation).html("");
		}
	}
}

function ProposalForChangePropertyValue(prefix, ONT) {
	this.form_fields = {
		reasonForChange: { element: jQuery("#" + prefix + "create_change_prop_value_reasonForChange"),
			errorMessage: "Please enter the rationale for this proposal",
			errorLocation: jQuery("#" + prefix + "create_change_prop_value_reasonForChange").attr("id") + "_error"
		},
		contactInfo: { element: jQuery("#" + prefix + "create_change_prop_value_contactInfo") },
		propertyId: { element: jQuery("#" + prefix + "propertyId"),
			errorMessage: "Please enter the id of the property you would like to change",
			errorLocation: jQuery("#" + prefix + "propertyId").attr("id") + "_error"
		},
		newPropertyValue: { element: jQuery("#" + prefix + "newPropertyValue"),
			errorMessage: "Please enter the new property value",
			errorLocation: jQuery("#" + prefix + "newPropertyValue").attr("id") + "_error"
		},
		oldPropertyValue: jQuery("#" + prefix + "oldPropertyValue")
	}

	this.required = [ "reasonForChange", "newPropertyValue", "propertyId" ];
	
	this.failedValidation;
	
	// Contains the values that we want to submit
	this.member_variables = {
		ontology_virtual_id: ONT,
		appliesTo: jQuery("#" + prefix + "create_change_prop_value_appliesTo").val(),
		appliesToType: jQuery("#" + prefix + "create_change_prop_value_appliesToType").val(),
		type: jQuery("#" + prefix + "create_change_prop_value_noteType").val(),
		author: jQuery("#" + prefix + "create_change_prop_value_author").val(),
		subject: getNoteTypeText(jQuery("#" + prefix + "create_change_prop_value_noteType").val()) + ": "
			+ jQuery("#" + prefix + "propertyId").val(), // Special text plus preferred name
		body: jQuery("#" + prefix + "create_change_prop_value_body").val(),
		reasonForChange: jQuery("#" + prefix + "create_change_prop_value_reasonForChange").val(),
		contactInfo: jQuery("#" + prefix + "create_change_prop_value_contactInfo").val(),
		propertyId: jQuery("#" + prefix + "propertyId").val(),
		newPropertyValue: jQuery("#" + prefix + "newPropertyValue").val(),
		oldPropertyValue: jQuery("#" + prefix + "oldPropertyValue").val()
	}
	
	this.validate = function() {
		for (field in this.form_fields) {
			if (jQuery.inArray(field, this.required) >= 0 && this.form_fields[field].element.val() === "") {
				this.failedValidation = true;
				jQuery("#" + this.form_fields[field].errorLocation).html("<br/>" + this.form_fields[field].errorMessage);
			} else {
				jQuery("#" + this.form_fields[field].errorLocation).html("");
			}
		}
	}
	
	this.reset = function() {
		for (field in this.form_fields) {
			this.form_fields[field].element.val("");
			jQuery("#" + this.form_fields[field].errorLocation).html("");
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

function getNoteTypeText(note_type) {
	switch (note_type) {
	case "Comment":
		return "Comment";
	case "ProposalForCreateEntity":
		return "New Term Proposal";
	case "ProposalForChangeHierarchy":
		return "New Relationship Proposal";
	case "ProposalForChangePropertyValue":
		return "Change Property Value Proposal";
	default:
		return "";
	}
}
