// Note duplicated code in _visits.html.haml due to Ajax loading
jQuery(document).data().bp.ontChart = {};

jQuery(document).data().bp.ontChart.init = function() {
  Chart.defaults.global.scaleLabel = jQuery(document).data().bp.ont_chart.scaleLabel;
  var data = {
    labels: jQuery(document).data().bp.ont_chart.visitsLabels,
    datasets: [
      {
        label: "Visits",
        backgroundColor: "rgba(151,187,205,0.2)",
        borderColor: "rgba(151,187,205,1)",
        pointBorderColor: "rgba(151,187,205,1)",
        pointBackgroundColor: "rgba(151,187,205,1)",
        data: jQuery(document).data().bp.ont_chart.visitsData
      }
    ]
  };

  var visits_chart = document.getElementById("visits_chart");
  if (visits_chart) {
    var ctx = visits_chart.getContext("2d");

    var myLineChart = new Chart(ctx, {
      type: 'line',
      data: data,
      options: { responsive: true }
    });
  }
};