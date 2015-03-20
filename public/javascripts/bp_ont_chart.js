// Note duplicated code in _visits.html.haml due to Ajax loading
jQuery(document).ready(function() {
  if (typeof Chart !== 'undefined' && !jQuery(document).data().bp.ont_chart.chartInstantiated) {
    Chart.defaults.global.scaleLabel = jQuery(document).data().bp.ont_chart.scaleLabel;

    var data = {
        labels: jQuery(document).data().bp.ont_chart.visitsData,
        datasets: [
            {
                label: "Visits",
                fillColor: "rgba(151,187,205,0.2)",
                strokeColor: "rgba(151,187,205,1)",
                pointColor: "rgba(151,187,205,1)",
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(151,187,205,1)",
                data: jQuery(document).data().bp.ont_chart.visitsData
            }
        ]
    };
    var ctx = document.getElementById("visits_chart").getContext("2d");
    var myLineChart = new Chart(ctx).Line(data, { responsive: true });
    jQuery(document).data().bp.ont_chart.chartInstantiated = true;
  }
});
