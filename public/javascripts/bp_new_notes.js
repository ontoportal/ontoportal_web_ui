jQuery(document).ready(function(){
  jQuery("a.notes_list_link").attr("rel", "facebox[.facebox_note]");
  jQuery("a.notes_list_link").facebox();
  jQuery(document).bind('afterReveal.facebox', function() {
    jQuery("div.facebox_note").parents("div#facebox").width('850px');
    jQuery("div.facebox_note").width('820px');
    jQuery("div.facebox_note").parents("div#facebox").css("max-height", jQuery(window).height() - (jQuery("#facebox").offset().top - jQuery(window).scrollTop()) * 2 + "px");
    jQuery("div.facebox_note").parents("div#facebox").centerElement();
  });

  jQuery("a.reply_reply").live('click', function(){
    var parent = jQuery(this).attr("data-parent_id");
    var note = jQuery(this).attr("data-note_id");
    var id = (typeof parent === "undefined") ? note : parent;
    var type = (typeof parent === "undefined") ? "note" : "parent";
    var form = '<div><textarea rows="1" cols="1" name="text" tabindex="0" style="width: 500px; height: 100px;"></textarea></div>';
    var buttons = '<button type="submit" data-parent_id="'+id+'" data-parent_type="'+type+'" onclick="" class="save" style="">save</button><button type="button" onclick="" class="cancel" style="">cancel</button><span class="reply_status"></span>';
    jQuery(this).parents("div.reply").append(jQuery("<div>").addClass("reply_box").html(form + buttons));
    jQuery(this).hide();
  });

  jQuery(".reply .cancel").live('click', function(){
    removeReplyBox(this);
  });

  jQuery(".reply .save").live('click', function(){
    var id = jQuery(this).attr("data-parent_id");
    var type = jQuery(this).attr("data-parent_type");
    var button = this;
    jQuery(this).parents("div.reply").children(".reply_author").children("a.reply_reply").show();
    jQuery.ajax({
      type: "POST",
      url: "/notes",
      data: {parent: id, type: type},
      success: function(){
        removeReplyBox(button);
        addReply(button);
      },
      error: function(){
        // Output error text
      }
    });


  });
});

function addReply(button) {

}

function removeReplyBox(button) {
  jQuery(button).parents("div.reply").children(".reply_author").children("a.reply_reply").show();
  jQuery(button).closest("div.reply_box").remove();
}