jQuery(document).ready(function(){
  setupFacebox();
  bindReplyClick();
  bindReplyCancelClick();
  bindReplySaveClick();
});

function setupFacebox() {
  jQuery("a.notes_list_link").attr("rel", "facebox[.facebox_note]");
  jQuery("a.notes_list_link").facebox();
  jQuery(document).bind('afterReveal.facebox', function() {
    jQuery("div.facebox_note").parents("div#facebox").width('850px');
    jQuery("div.facebox_note").width('820px');
    jQuery("div.facebox_note").parents("div#facebox").css("max-height", jQuery(window).height() - (jQuery("#facebox").offset().top - jQuery(window).scrollTop()) * 2 + "px");
    jQuery("div.facebox_note").parents("div#facebox").centerElement();
  });
}

function bindReplyClick() {
  jQuery("a.reply_reply").live('click', function(){
    addReplyBox(this);
    jQuery(this).hide();
  });
}

function bindReplyCancelClick() {
  jQuery(".reply .cancel").live('click', function(){
    removeReplyBox(this);
  });
}

function bindReplySaveClick() {
  jQuery(".reply .save").live('click', function(){
    var id = jQuery(this).attr("data-parent_id");
    var type = jQuery(this).attr("data-parent_type");
    var button = this;
    var body = jQuery(this).closest(".reply_box").children(".reply_body").val();
    jQuery(button).parent().children(".reply_status").html("");
    jQuery.ajax({
      type: "POST",
      url: "/notes",
      data: {parent: id, type: type, body: body, creator: jQuery(document).data().bp.user["@id"]},
      success: function(data){
        var note = data;
        var status = data[1];
        console.log(data);
        console.log(status >= 400);
        console.log(note["@id"]);
        if (status >= 400) {
          displayError(button);
        } else {
          addReply(button, note);
          removeReplyBox(button);
        }
      },
      error: function(){displayError(button);}
    });
  });
}

function validateReply(button) {

}

var displayError = function(button) {
  jQuery(button).parent().children(".reply_status").html("Error, please try again");
}

function addReply(button, note) {
  var username = jQuery(document).data().bp.user["username"];
  var reply = jQuery("<div>").addClass("reply");
  var replyAuthor = jQuery("<div>").addClass("reply_author").html("<b>"+username+"</b> seconds ago");
  var replyBody = jQuery("<div>").addClass("reply_body").html(note.body);
  var replyMeta = jQuery("<div>").addClass("reply_meta");
  replyMeta.append(jQuery("<a>").addClass("reply_reply").attr("data-parent_id", note["@id"]).attr("href", "#reply").html("reply"));
  reply.append(replyAuthor).append(replyBody).append(replyMeta);
  console.log("Adding reply");
  console.log(reply);
  console.log(jQuery(button).closest("div.reply").children(".discussion").children(".discussion_container"));
  jQuery(button).closest("div.reply").children(".discussion").children(".discussion_container").prepend(reply);
}

function addReplyBox(button) {
  var parent = jQuery(button).attr("data-parent_id");
  var note = jQuery(button).attr("data-note_id");
  var id = (typeof parent === "undefined") ? note : parent;
  var type = (typeof parent === "undefined") ? "note" : "parent";
  var form = '<textarea class="reply_body" rows="1" cols="1" name="text" tabindex="0" style="width: 500px; height: 100px;"></textarea><br/>';
  var buttons = '<button type="submit" data-parent_id="'+id+'" data-parent_type="'+type+'" onclick="" class="save" style="">save</button><button type="button" onclick="" class="cancel" style="">cancel</button><span class="reply_status"></span>';
  jQuery(button).closest("div.reply").children("div.reply_meta").append(jQuery("<div>").addClass("reply_box").html(form + buttons));
}
function removeReplyBox(button) {
  jQuery(button).closest("div.reply").children(".reply_meta").children("a.reply_reply").show();
  jQuery(button).closest("div.reply").children(".reply_meta").children(".reply_box").remove();
}