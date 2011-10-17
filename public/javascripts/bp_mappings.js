function deleteMappings() {
  var mappingsToDelete = [], params;

  jQuery("#delete_mappings_spinner").show();

  jQuery("input[name='delete_mapping']:checked").each(function(){
    mappingsToDelete.push(jQuery(this).val());
  });

  params = {
    mappingids: mappingsToDelete.join(","),
    _method: "delete",
    ontologyid: ontology_id,
    conceptid: concept_id
  };

  jQuery("#delete_mappings_error").html("");

  jQuery.ajax({
      url: "/mappings/mappingids",
      type: "POST",
      data: params,
      success: function(data){
        var rowId;

        jQuery("#delete_mappings_spinner").hide();

        for (map_id in data.success) {
          rowId = data.success[map_id].replace(/.*\//, "");
          jQuery("#" + rowId).html("").hide();
        }

        for (map_id in data.error) {
          rowId = data.error[map_id].replace(/.*\//, "");
          jQuery("#" + rowId).css("border", "red solid");
        }

        jQuery("#mapping_count").html(jQuery("#mapping_details tbody tr:visible").size());
      },
      failure: function(){
        jQuery("#delete_mappings_spinner").hide();
        jQuery("#delete_mappings_error").html("There was a problem deleting, please try again");
      }
  });
}



