jQuery(document).ready(function(){
  // Select all users in the list by default
  jQuery("#ontology_acl option").attr("selected","selected");

  // Make the list styled with chosen
  jQuery("#ontology_acl").chosen();

  // Add account button wire
  jQuery("#user_acl_add_button").bind("click", validateUsername);

  // Respond to enter press on account add
  jQuery("#useracl_user_acl_add").keypress(function(event){
    if (event.which == 13) {
      event.preventDefault();
      jQuery("#user_acl_add_button").click();
    }
  });

  // Maintain the user acl select list, remove unselected options every time somone click's the "X"
  jQuery("#ontology_acl").change(function(){
    // Delete unselected options
    jQuery("#ontology_acl option").each(function(){
      if (!jQuery(this).attr("selected")) {
        jQuery(this).remove();
      }
    });

    jQuery("#ontology_acl option").attr("selected","selected");
  });
});

validateUsername = function(event){
  jQuery(".user_acl_add_error").html("");
  jQuery(".user_acl_add_spinner").show();

  jQuery.ajax({
        type: "POST",
        url: "/users/validate_username?username="+jQuery("#useracl_user_acl_add").val(),
        dataType: "json",
        success: function(data) {
          jQuery(".user_acl_add_spinner").hide();

          if (data.userValid == true) {
            jQuery("#useracl_user_acl_add").val("");
            jQuery("#useracl_user_acl_add").focus();

            // Only add the user to the list if they don't already exist
            if (!jQuery("#ontology_acl option[value='"+data.user.id+"']").length) {
              jQuery('#ontology_acl').append($('<option>', { "value" : data.user.id, "selected" : "selected" }).text(data.user.username));
              jQuery("#ontology_acl option").attr("selected","selected");
            }

            jQuery('#ontology_acl').trigger("change");
            jQuery('#ontology_acl').trigger("liszt:updated");
          } else {
            jQuery(".user_acl_add_error").html(" Username does not exist");
          }
        },
        error: function(data) {
          jQuery(".user_acl_add_spinner").hide();
          jQuery(".user_acl_add_error").html(" Problem adding user, please try again");
        }
  });
};
