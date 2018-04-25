function numberWithCommas(x) {
  return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function jumpToValueOntology() {
  var ontology = jQuery("#find_ontology")[0].value;
  var ontology_id = jQuery("#find_ontology_id").val();

  if (ontology_id == null || ontology_id == "") {
    // didnt pick an ont
    alert("The ontology does not exist. You must pick an ontology from the list.")

    return false;
  }

  if (!!ontology_id) {
    var sValue = jQuery("#find_ontology_id").val();
    if (sValue == null || sValue == "") {
      sValue = data;
    }
    document.location="/ontologies/"+sValue;
    jQuery.blockUI({ message: '<h1>#{image_tag("jquery.simple.tree/spinner.gif")} Loading Ontology...</h1>' });
    return;
  }
}

function formatResultOntologySearch(value, data) {
  jQuery("#find_ontology_id").val("");
  var specials = new RegExp("[.*+?|()\\[\\]{}\\\\]", "g"); // .*+?|()[]{}\
  var keywords = jQuery("#find_ontology").val().replace(specials, "\\$&").split(' ').join('|');
  var regex = new RegExp( '(' + keywords + ')', 'gi' );
  return value.replace(regex, "<b><span style='color:#006600;'>$1</span></b>");
}

function jumpToValueResource(){
  var cls = jQuery("#find_resource")[0].value;
  var data = jQuery('body').data("resource_results");

  if (data == null) {
    // I'm doing a search
    var search = confirm("Press OK to Search for resources using the concept, or Cancel to select a concept")
    if (search) {
      query = jQuery("#find_resource").val();
      document.location="/resource_index";
      return;
    }
  }

  if (!!data) {
    var concept_id = data[0];
    var ontology_version_id = data[2];
    var ontology_id = data[7];
    var full_ontology_id = jQuery(document).data().bp.config.rest_url + "/ontologies/" + ontology_id;
    window.location = "/resource_index/resources?classes[" + encodeURIComponent(full_ontology_id) + "]=" + encodeURIComponent(concept_id);
    return;
  }
}

function formatItemResource(value, data) {
  jQuery('body').data("resource_results", null);
  var specials = new RegExp("[.*+?|()\\[\\]{}\\\\]", "g"); // .*+?|()[]{}\
  var keywords = jQuery("#find_resource").val().replace(specials, "\\$&").split(' ').join('|');
  var regex = new RegExp( '(' + keywords + ')', 'gi' );

  // data[7] is the ontology_id, only included when searching multiple ontologies
  if (data[6] == undefined) {
    var result = value.replace(regex, "<b><span style='color:#006600;'>$1</span></b>") + " <span style='font-size:9px;color:blue;'>(" + data[1] + ")</span>";
  } else {
    var result = value.replace(regex, "<b><span style='color:#006600;'>$1</span></b>") + " <span style='font-size:9px;color:blue;'>(" + data[1] + ")</span>" + "<span style='color:grey;font-size:7pt;'> from: " + data[6] + "</span>";
  }

  return result;
}

// We use this in conjunction with autocomplete because autocomplete
// fails when there are multiple results with the same class name
function selectResource(value, data) {
  jQuery('body').data("resource_results", value.data);
  jumpToValueResource();
}

// Sets a hidden form value that records the virtual id when a concept is chosen in the jump to
// This is a workaround because the default autocomplete search method cannot distinguish between two
// ontologies that have the same preferred name but different ids.
function selectFindOntology(value, data){
  jQuery("#find_ontology_id").val(value.data[0]);
  jQuery("#find_ontology").focus();
  jumpToValueOntology();
}

var ontologies_array = [];
var findOntologyInput = document.getElementById("find_ontology");
if (findOntologyInput) {
  ontologies_array = JSON.parse(findOntologyInput.dataset.ontologynames);
}

jQuery(document).ready(function() {
  jQuery("#find_ontology").autocomplete({
    selectFirst: true,
    data: ontologies_array,
    minChars: 1,
    matchSubset: 1,
    maxItemsToShow: 20,
    delay: 1,
    showResult: formatResultOntologySearch,
    onItemSelect: selectFindOntology
  });

  jQuery("#find_resource").autocomplete({
    selectFirst: true,
    url: "/search/json_search/",
    extraParams: { separator: "\n" },
    cacheLength: 1,
    maxCacheLength: 1,
    matchSubset: 0,
    minChars: 3,
    maxItemsToShow: 20,
    showResult: formatItemResource,
    onItemSelect: selectResource
  });

  jQuery('ul.sf-menu').superfish({
    animation: {height:'show'},   // slide-down effect without fade-in
    delay:     1200               // 1.2 second delay on mouseout);
  });

  var visitsChartDiv = document.getElementById("ontology-visits-chart");

  if (visitsChartDiv) {
    var ontNamesObject = JSON.parse(visitsChartDiv.dataset.ontnames);
    var ontNames = Object.keys(ontNamesObject);
    var ontNumbers = JSON.parse(visitsChartDiv.dataset.ontnumbers);
    var onts = JSON.parse(visitsChartDiv.dataset.ontnames);
    var ctx = document.getElementById("myChart");

    var myChart = new Chart(ctx, {
      type: 'horizontalBar',
      data: {
        labels: ontNames,
        datasets: [{
          label: "Ontology Visits",
          data: ontNumbers,
          backgroundColor: "rgba(151,187,205,0.2)",
          borderColor: "rgba(151,187,205,1)",
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        legend: {
          display: false
        },
        scales: {
          xAxes: [{
            ticks: {
              beginAtZero: true,
              stepSize: 5000,
              // Return an empty string to draw the tick line but hide the tick label
              // Return `null` or `undefined` to hide the tick line entirely
              userCallback: function(value, index, values) {
                return numberWithCommas(value);
              }
            }
          }],
          yAxes: [{
            ticks: {}
          }]
        },
        tooltips: {
          enabled: true,
          callbacks: {
            title: function(tooltipItems, data) {
              lbl = onts[tooltipItems[0].yLabel];

              if (lbl.length > 45) {
                lbl = lbl.substring(0, 37) + "...";
              }
              return lbl + " (" + tooltipItems[0].yLabel + ")";
            },
            label: function(tooltipItem, data) {
              return data.datasets[0].label + ": " + numberWithCommas(tooltipItem.xLabel);
            }
          }
        },
        hover: {
          onHover: function(e) {
            jQuery("#myChart").css("cursor", e[0] ? "pointer" : "default");
          }
        }
      }
    });

    ctx.onclick = function(evt) {
      var activePoints = myChart.getElementsAtEvent(evt);

      if (activePoints.length > 0) {
        // get the internal index of slice in pie chart
        var clickedElementIndex = activePoints[0]["_index"];
        // get specific label by index
        var label = myChart.data.labels[clickedElementIndex];
        // get value by index
        // var value = myChart.data.datasets[0].data[clickedElementIndex];
        window.location.href = "/ontologies/" + label;
      }
    }
  }
});