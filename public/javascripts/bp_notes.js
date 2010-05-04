/**
 * @author palexander
 */

var NOTES_URL = "/notes/";

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
		
		switch (note_type) {
		case "create_comment":
			var note = new Comment(prefix);
			note.validate();
			break;
		case "create_new_term":
			var note = new ProposalForNewEntity(prefix);
			note.validate();
			break;
		case "create_change_hierarchy":
			var note = new ProposalForChangeHierarchy(prefix);
			note.validate();
			break;
		case "create_change_prop_value":
			var note = new ProposalForPropertyValueChange(prefix);
			note.validate();
		}
		
		jQuery.ajax({
				type: "POST",
				url: NOTES_URL,
				data: note.member_variables,
				dataType: "json",
				success: function(data) {
					// Get JSON response for new row and add if successful
					jQuery.get("/notes/ajax/single_list/" + data.ontologyId + "?noteid=" + data.id,
							function(json) {
								// Check for "No notes" message and delete
								var no_notes_check = document.getElementById("no_notes");
								if (no_notes_check != null) {
									oTable.fnDeleteRow(oTable.fnGetPosition(document.getElementById("no_notes")));
								}
								
								
		
								oTable.fnAddData([
			  	                    json.subject + "",
			  	                    json.body + "",
			  	                    json.author + "",
			  	                    json.type + "",
			  	                	json.appliesTo + "",
			  	                	json.created + ""
			                    ]);
								
								note.reset();
								
								// update note_count
								
								//   window.scrollTo(0,$("#"+id).offset().top);
							}
					);
					
				},
				error: function(XMLHttpRequest, textStatus, errorThrown) {
					
				}
		});
	});
	
});

function Comment(prefix) {
	var BP_REST_URL = jQuery("#BP_REST_URL").val();
	var ONT = jQuery("#ONT").val();
	
	this.form_fields = {
		appliesTo: jQuery("#" + prefix + "create_comment_appliesTo"),
		appliesToType: jQuery("#" + prefix + "create_comment_appliesToType"),
		type: jQuery("#" + prefix + "create_comment_noteType"),
		author: jQuery("#" + prefix + "create_comment_author"),
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

function ProposalForNewEntity(prefix) {
	var BP_REST_URL = jQuery("#BP_REST_URL").val();
	var ONT = jQuery("#ONT").val();
	
	this.form_fields = {
			appliesTo: jQuery("#" + prefix + "create_new_term_appliesTo"),
			appliesToType: jQuery("#" + prefix + "create_new_term_appliesToType"),
			type: jQuery("#" + prefix + "create_new_term_noteType"),
			author: jQuery("#" + prefix + "create_new_term_author"),
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
		newTermDefinition: jQuery("#" + prefix + "termDefinition").val(),
		newTermId: jQuery("#" + prefix + "termId").val(),
		newTermParent: jQuery("#" + prefix + "termParent").val(),
		newTermPreferredName: jQuery("#" + prefix + "termPreferredName").val(),
		newTermSynonyms: jQuery("#" + prefix + "termSynonyms").val()
	}
	
	this.validate = function() {
		
	}
	
	this.reset = function() {
		for (field in this.form_fields) {
			this.form_fields[field].val("");
		}
	}
}

function ProposalForChangeHierarchy(prefix) {
	var BP_REST_URL = jQuery("#BP_REST_URL").val();
	var ONT = jQuery("#ONT").val();
	
	this.form_fields = {
			appliesTo: jQuery("#" + prefix + "create_change_hierarchy_appliesTo"),
			appliesToType: jQuery("#" + prefix + "create_change_hierarchy_appliesToType"),
			type: jQuery("#" + prefix + "create_change_hierarchy_noteType"),
			author: jQuery("#" + prefix + "create_change_hierarchy_author"),
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

function ProposalForPropertyValueChange(prefix) {
	var BP_REST_URL = jQuery("#BP_REST_URL").val();
	var ONT = jQuery("#ONT").val();
	
	this.form_fields = {
			appliesTo: jQuery("#" + prefix + "create_change_prop_value_appliesTo"),
			appliesToType: jQuery("#" + prefix + "create_change_prop_value_appliesToType"),
			type: jQuery("#" + prefix + "create_change_prop_value_noteType"),
			author: jQuery("#" + prefix + "create_change_prop_value_author"),
			subject: jQuery("#" + prefix + "create_change_prop_value_subject"),
			body: jQuery("#" + prefix + "create_change_prop_value_body"),
			reasonForChange: jQuery("#" + prefix + "create_change_prop_value_reasonForChange"),
			contactInfo: jQuery("#" + prefix + "create_change_prop_value_contactInfo"),
			propertyId: jQuery("#" + prefix + "propertyId"),
			propertyNewValue: jQuery("#" + prefix + "propertyNewValue"),
			propertyOldValue: jQuery("#" + prefix + "propertyOldValue")
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
		propertyNewValue: jQuery("#" + prefix + "propertyNewValue").val(),
		propertyOldValue: jQuery("#" + prefix + "propertyOldValue").val()
	}
	
	this.validate = function() {
		
	}
	
	this.reset = function() {
		for (field in this.form_fields) {
			this.form_fields[field].val("");
		}
	}
}