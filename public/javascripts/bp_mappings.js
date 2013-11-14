// The count returned may not match the actual number of mappings
// To get around this, we re-calculate based on the mapping table size
jQuery(document).ready(function(){
  calculateMappingCount();
  jQuery("#delete_mappings_permission").hide(); // Ensure we can't see the permission checkbox.
  var mapping_permission = jQuery("#delete_mappings_permission").is(':checked');
  if (mapping_permission === true) {
    jQuery("#delete_mappings_button").show();
  } else {
    jQuery("#delete_mappings_button").hide();
  }
});

jQuery(document).bind("tree_changed", calculateMappingCount);

function calculateMappingCount() {
  var rows = jQuery("#concept_mappings_table tbody tr");
  var mappings_count;
  if (rows.length == 1 && jQuery(rows).children("td")[0].getAttribute("colspan") > 1) {
    mappings_count = 0;
  } else {
    mappings_count = rows.length;
  }
  jQuery("#mapping_count").html(mappings_count);
}

function deleteMappings() {
  var mappingsToDelete = [], params;

  jQuery("#delete_mappings_error").html("");
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
          jQuery("#delete_mappings_error").html("There was a problem deleting, please try again");
          rowId = data.error[map_id].replace(/.*\//, "");
          jQuery("#" + rowId).css("border", "red solid");
        }

        jQuery("#mapping_count").html(jQuery("#mapping_details tbody tr:visible").size());

        jQuery.bioportal.ont_pages["mappings"].retrieve_and_publish();
      },
      error: function(){
        jQuery("#delete_mappings_spinner").hide();
        jQuery("#delete_mappings_error").html("There was a problem deleting, please try again");
      }
  });
}



