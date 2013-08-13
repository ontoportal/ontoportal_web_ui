jQuery(document).ready(function(){
  setupFacebox();
  setupFaceboxSizing();
  bindAddCommentClick();
  bindAddProposalClick();
  bindProposalChange();
  bindReplyClick();
  bindReplyCancelClick();
  bindReplySaveClick();
});

NOTES_PROPOSAL_TYPES = {
  "ProposalNewClass": "New Class Proposal",
  "ProposalChangeHierarchy": "New Relationship Proposal",
  "ProposalChangeProperty": "Change Property Value Proposal"
}

function setupFacebox() {
  jQuery("a.notes_list_link").attr("rel", "facebox[.facebox_note]");
  jQuery("a.notes_list_link").facebox();
}

function setupFaceboxSizing() {
  jQuery(document).bind('afterReveal.facebox', function() {
    jQuery("div.facebox_note").parents("div#facebox").width('850px');
    jQuery("div.facebox_note").width('820px');
    jQuery("div.facebox_note").parents("div#facebox").css("max-height", jQuery(window).height() - (jQuery("#facebox").offset().top - jQuery(window).scrollTop()) * 2 + "px");
    jQuery("div.facebox_note").parents("div#facebox").centerElement();
  });
}

function bindAddCommentClick() {
  jQuery("a.add_comment").live('click', function(){
    var id = jQuery(this).attr("data-parent_id");
    var type = jQuery(this).attr("data-parent_type");
    addCommentBox(id, type, this);
  });
}

function bindAddProposalClick() {
  jQuery("a.add_proposal").live('click', function(){
    var id = jQuery(this).attr("data-parent_id");
    var type = jQuery(this).attr("data-parent_type");
    addProposalBox(id, type);
  });
}

function bindReplyClick() {
  jQuery("a.reply_reply").live('click', function(){
    addReplyBox(this);
    jQuery(this).hide();
  });
}

function bindReplyCancelClick() {
  jQuery(".reply .cancel, .create_note_form .cancel").live('click', function(){
    removeReplyBox(this);
  });
}

function bindProposalChange() {
  jQuery(".create_note_form .proposal_type").live('change', function(){
    var selector = jQuery(this);
    proposalFields(selector.val(), selector.parent().children(".proposal_container"));
  });
}

function bindReplySaveClick() {
  jQuery(".reply .save, .create_note_form .save").live('click', function(){
    var id = jQuery(this).attr("data-parent_id");
    var type = jQuery(this).attr("data-parent_type");
    var button = this;
    var body = jQuery(this).closest(".reply_box").children(".reply_body").val();
    var subject = subjectForNote(button);
    jQuery(button).parent().children(".reply_status").html("");
    if (type === "class") {
      id = {class: id, ontology: ontology_id};
    }
    jQuery.ajax({
      type: "POST",
      url: "/notes",
      data: {parent: id, type: type, subject: subject, body: body, proposal: proposalMap(), creator: jQuery(document).data().bp.user["@id"]},
      success: function(data){
        var note = data;
        var status = data[1];
        if (status >= 400) {
          displayError(button);
        } else {
          addNoteOrReply(button, note);
          removeReplyBox(button);
        }
      },
      error: function(){displayError(button);}
    });
  });
}

function validateReply(button) {

}

function validateNote(button) {

}

function validateProposal(button) {

}

var displayError = function(button) {
  jQuery(button).parent().children(".reply_status").html("Error, please try again");
}

function addCommentBox(id, type, button) {
  var formContainer = jQuery(button).parents(".notes_list_container").children(".create_note_form");
  var commentFormHTML = jQuery("<div>").addClass("reply_box").html(commentForm(id, type));
  commentFormHTML.prepend("<br>").prepend(jQuery("<input>").attr("type", "text").attr("placeholder", "Subject").addClass("reply_body").addClass("comment_subject"));
  formContainer.html(commentFormHTML);
  formContainer.show();
}

function addProposalBox(id, type) {
  var proposalForm = jQuery("<div>").addClass("reply_box");
  var select = jQuery("<select>").addClass("proposal_type");
  var proposalContainer;
  for (var proposalType in NOTES_PROPOSAL_TYPES) {
    select.append(jQuery("<option>").attr("value", proposalType).html(NOTES_PROPOSAL_TYPES[[proposalType]]));
  }
  proposalForm.html("Proposal type: ");
  proposalForm.append(select);
  proposalForm.append("<br/>");

  proposalContainer = jQuery("<div>").addClass("proposal_container");

  // Proposal-specific fields
  proposalFields(Object.keys(NOTES_PROPOSAL_TYPES).shift(), proposalContainer);

  proposalForm.append(proposalContainer);
  proposalForm.append(jQuery("<div>").addClass("proposal_buttons").append(commentButtons(id, type)));
  jQuery(".create_note_form").html(proposalForm);
  jQuery(".create_note_form").show();
}

function addNoteOrReply(button, note) {
  if (note["@type"] === "http://data.bioontology.org/metadata/Note") {
    // Create a new note in the note table
    addNote(button, note);
  } else if (note["@type"] === "http://data.bioontology.org/metadata/Reply") {
    // Create a new reply in the thread
    addReply(button, note);
  }
}

function addNote(button, note) {
  var username = jQuery(document).data().bp.user["username"];
  var id = note["@id"].split("/").pop();
  var noteLink = generateNoteLink(id, note);
  var noteLinkHTML = jQuery("<div>").append(noteLink).html();
  var created = note["created"].split("T")[0];
  // TODO_REV: Add column for note delete checkbox
  var deleteBox = "";
  var noteType = getNoteType(note);
  var noteRow = [deleteBox, noteLinkHTML, note["subject"], "false", username, noteType, "", created];
  // Add note to concept table (if we're on a concept page)
  if (jQuery(button).closest("#notes_content").length > 0) {
    var jRow = jQuery("<tr>");
    jRow.append(jQuery("<td>").html(generateNoteLink("concept_"+id, note)));
    jRow.append(jQuery("<td>").html(username));
    jRow.append(jQuery("<td>").html(noteType));
    jRow.append(jQuery("<td>").html(created));
    jQuery("table.concept_notes_list").prepend(jRow);
    jQuery("#note_count").html(parseInt(jQuery("#note_count").html()) + 1);
    jQuery("a#concept_"+id).facebox();
  }
  // Add note to main table
  if (typeof ontNotesTable !== "undefined") {
    ontNotesTable.fnAddData(noteRow);
  }
  jQuery("a#"+id).facebox();
}

function addReply(button, note) {
  var username = jQuery(document).data().bp.user["username"];
  var reply = jQuery("<div>").addClass("reply");
  var replyAuthor = jQuery("<div>").addClass("reply_author").html("<b>"+username+"</b> seconds ago");
  var replyBody = jQuery("<div>").addClass("reply_body").html(note.body);
  var replyMeta = jQuery("<div>").addClass("reply_meta");
  replyMeta.append(jQuery("<a>").addClass("reply_reply").attr("data-parent_id", note["@id"]).attr("href", "#reply").html("reply"));
  reply.append(replyAuthor).append(replyBody).append(replyMeta);
  jQuery(button).closest("div.reply").children(".discussion").children(".discussion_container").prepend(reply);
}

function addReplyBox(button) {
  var id = jQuery(button).attr("data-parent_id");
  var type = jQuery(button).attr("data-parent_type");
  var formHTML = commentForm(id, type);
  jQuery(button).closest("div.reply").children("div.reply_meta").append(jQuery("<div>").addClass("reply_box").html(formHTML));
}

function removeReplyBox(button) {
  jQuery(button).closest("div.reply").children(".reply_meta").children("a.reply_reply").show();
  jQuery(button).closest("div.reply").children(".reply_meta").children(".reply_box").remove();
  jQuery(button).closest(".create_note_form").html("");
}

function commentForm(id, type) {
  var form = '<textarea class="reply_body" rows="1" cols="1" name="text" tabindex="0" style="width: 500px; height: 100px;" placeholder="Comment"></textarea><br/>';
  return form + commentButtons(id, type);
}

function commentButtons(id, type) {
  return '<button type="submit" data-parent_id="'+id+'" data-parent_type="'+type+'" onclick="" class="save">save</button><button type="button" onclick="" class="cancel" style="">cancel</button><span class="reply_status"></span>';
}

function appendField(id, text, div) {
  if (jQuery.browser.msie && parseInt(jQuery.browser.version) < 10) {
    div.append(jQuery("<span>").css("font-weight", "bold").html(text));
    div.append("<br/>");
  }
  div.append(jQuery("<input>").attr("type", "text").attr("id", id).attr("placeholder", text));
  div.append("<br/>");
}

function proposalFields(type, container) {
  container.html("");
  appendField("reasonForChange", "Reason for change", container);
  if (type === "ProposalChangeHierarchy") {
    appendField("newTarget", "New target", container);
    appendField("oldTarget", "Old target", container);
    appendField("newRelationshipType", "Relationship type", container);
  } else if (type === "ProposalChangeProperty") {
    appendField("propertyId", "Property id", container);
    appendField("newValue", "New value", container);
    appendField("oldValue", "Old Value", container);
  } else if (type === "ProposalNewClass") {
    appendField("classId", "Class id", container);
    appendField("label", "Label", container);
    appendField("synonym", "Synonym", container);
    appendField("definition", "Definision", container);
    appendField("parent", "Parent", container);
  }
}

function proposalMap() {
  var lists = ["synonym", "definition", "newRelationshipType"];
  var map = {};
  map["type"] = jQuery(".create_note_form .proposal_type").val();
  jQuery(".proposal_container input").each(function(){
    var input = jQuery(this);
    var id = input.attr("id");
    var val = (jQuery.inArray(id, lists) >= 0) ? input.val().split(",") : input.val();
    map[id] = val;
  });
  return map;
}

function subjectForNote(button) {
  var subject = jQuery(button).closest(".reply_box").children(".comment_subject").val();
  var reasonForChange = jQuery("input#reasonForChange");
  if (typeof subject === "undefined" || (subject.length === 0 && reasonForChange.length > 0)) {
    subject = NOTES_PROPOSAL_TYPES[$(".proposal_type").val()] + ": " + reasonForChange.val();
  }
  return subject;
}

function generateNoteLink(id, note) {
  return jQuery("<a>")
    .addClass("ont_notes_list_link")
    .addClass("notes_list_link")
    .attr("href", "/ontologies/"+ontology_id+"/notes/"+encodeURIComponent(note["@id"]))
    .attr("id", id)
    .html(note["subject"]);
}

function getNoteType(note) {
  if (typeof note["proposal"] !== "undefined") {
    return NOTES_PROPOSAL_TYPES[note["proposal"][0]];
  } else {
    return "Comment";
  }
}