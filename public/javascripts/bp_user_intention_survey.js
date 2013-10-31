jQuery(document).ready(function(){
  new UserIntentionSurvey().bindTracker();
});

function UserIntentionSurvey() {
  var timeoutKey = "user_survey_timeout";

  this.bindTracker = function() {
    if (BP_getCookie(timeoutKey) === "true" || !USER_INTENTION_SURVEY) {
      return false;
    }

    var path = window.location.pathname.split("/");
    if (path.length > 2) return false;

    jQuery.get("/home/user_intention_survey", function(data){
      jQuery.facebox(data, "user_intention_survey");
    });

    jQuery(document).live("afterClose.facebox", function(){
      var survey = new UserIntentionSurvey();
      if (jQuery("#dont_show_again").is(":checked")) {
        survey.disablePermanently();
      } else {
        survey.disableTemporarily();
      }
      survey.submitSurvey();
    });

    jQuery("#intention_submit").live("click", function(){
      new UserIntentionSurvey().closeDialog();
    });

    jQuery("#intention_close").live("click", function(){
      new UserIntentionSurvey().closeDialog();
    });
  };

  this.timeoutKey = function() {
    return timeoutKey;
  };

  this.disablePermanently = function() {
    BP_setCookie(timeoutKey, true, {days: 365});
  };

  this.disableTemporarily = function() {
    BP_setCookie(timeoutKey, true, {days: 7});
  };

  this.closeDialog = function() {
    jQuery(document).trigger('close.facebox');
  };

  this.submitSurvey = function() {
    var params = new UserIntentionSurvey().surveyInformation();
    new Analytics().track("users", "intention_survey", params);
  };

  this.surveyInformation = function() {
    var info = {};
    info.intention_response = jQuery("#intention_response").val();
    info.contest_email = jQuery("#intention_email").val();
    info.page = window.location.href;
    return info;
  };
}