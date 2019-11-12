jQuery('.ontologies.show').ready(function() {

  var ontologyVisitsChartCanvas = document.getElementById('visits_chart');

  if (ontologyVisitsChartCanvas) {
    var labels = JSON.parse(ontologyVisitsChartCanvas.dataset.labels);
    var visits = JSON.parse(ontologyVisitsChartCanvas.dataset.visits);
    var context = ontologyVisitsChartCanvas.getContext('2d');

    var ontologyVisitsChart = new Chart(context, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: 'Visits',
          data: visits,
          backgroundColor: 'rgba(151, 187, 205, 0.2)',
          borderColor: 'rgba(151, 187, 205, 1)',
          pointBorderColor: 'rgba(151, 187, 205, 1)',
          pointBackgroundColor: 'rgba(151, 187, 205, 1)',
        }]
      },      
      options: { 
        responsive: true,
        legend: {
          display: false
        },
        scales: {
          yAxes: [{
            ticks: {
              beginAtZero: false,
              callback: function(value, index, values) {
                return numberWithCommas(value);
              }
            }
          }]
        },
        tooltips: {
          displayColors: false,
          callbacks: {
            label: function(tooltipItem, data) {
              return numberWithCommas(tooltipItem.yLabel);
            }
          }
        }
      }
    });
  }
});
