jQuery(document).ready(function() {

  jQuery('#createSynonymModal').on('shown.bs.modal', function(e) {
    let conceptLabel = jQuery("#createSynonymButton").data('concept-label');
    jQuery("h5#createSynonymModalLabel").text('Create synonym for ' + conceptLabel);
  });

});
