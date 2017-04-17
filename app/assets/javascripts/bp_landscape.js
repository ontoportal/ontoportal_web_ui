
// Creating a pie chart using d3pie.js
// function to generate a pie chart given 4 simple params: the div class name (the html div where the pie chart will go)
// the JSON containing the chart data. 2 strings for chart title and subtitle
var createPie = function(divName, json, title, subtitle) {
    new d3pie(divName, {
        "header": {
            "title": {
                "text": title,
                "fontSize": 22,
                "font": "open sans"
            },
            "subtitle": {
                "text": subtitle,
                "color": "#999999",
                "fontSize": 12,
                "font": "open sans"
            },
            "titleSubtitlePadding": 9
        },
        "footer": {
            "color": "#999999",
            "fontSize": 10,
            "font": "open sans",
            "location": "bottom-left"
        },
        "size": {
            "canvasWidth": document.getElementById(divName).offsetWidth,
            "pieOuterRadius": "90%"
        },
        "data": {
            "sortOrder": "value-desc",
            "content": json
        },
        "labels": {
            "truncation": {
              "enabled": true,
              "truncateLength": 40
            },
            "outer": {
                "pieDistance": 32
            },
            "inner": {
                "hideWhenLessThanPercentage": 3
            },
            "mainLabel": {
                "fontSize": 11
            },
            "percentage": {
                "color": "#ffffff",
                "decimalPlaces": 0
            },
            "value": {
                "color": "#adadad",
                "fontSize": 11
            },
            "lines": {
                "enabled": true
            }
        },
        "effects": {
            "pullOutSegmentOnClick": {
                "effect": "linear",
                "speed": 400,
                "size": 8
            }
        },
        "misc": {
            "gradient": {
                "enabled": true,
                "percentage": 100
            }
        }
    })
}

// To create a new pie chart: add "%div#prefLabelPieChartDiv" to html and use the createPie function
var naturalLanguagePie = createPie("naturalLanguagePieChartDiv", naturalLanguagePieJson, "Ontologies natural languages", "Languages of the ontologies");

var licensePie = createPie("licensePieChartDiv", licensePieJson, "Ontologies licenses", "Licenses used by the ontologies");

var prefLabelPie = createPie("prefLabelPropertyPieChartDiv", prefLabelPieJson, "Ontologies prefLabel properties", "prefLabel property URIs used for OWL ontologies");

var synonymPie = createPie("synonymPropertyPieChartDiv", synonymPieJson, "Ontologies synonym properties", "synonym property URIs used for OWL ontologies");

var definitionPie = createPie("definitionPropertyPieChartDiv", definitionPieJson, "Ontologies definition properties", "definition property URIs used for OWL ontologies");

var authorPie = createPie("authorPropertyPieChartDiv", authorPieJson, "Ontologies author properties", "author property URIs used for OWL ontologies");

// Generate the tag cloud

$(function() {
  // When DOM is ready, select the container element and call the jQCloud method, passing the array of words as the first argument.
  $("#peopleCloudChart").jQCloud(peopleCountJsonCloud);
});

$(function() {
  // When DOM is ready, select the container element and call the jQCloud method, passing the array of words as the first argument.
  $("#orgCloudChart").jQCloud(orgCountJsonCloud);
});


// Horizontal bar charts for format (OWL, SKOS, UMLS)
var ontologyFormatsContext = document.getElementById("formatCanvas").getContext("2d");

var ontologyFormatsChart = new Chart(ontologyFormatsContext, {
  type: 'horizontalBar',
  data: ontologyFormatsChartJson,
  options: {
    scales: {
      yAxes: [{
        stacked: true
      }]
    }
  }
});

var groupCountContext = document.getElementById("groupsCanvas").getContext("2d");

var groupCountChart = new Chart(groupCountContext, {
  type: 'bar',
  data: groupCountChartJson,
  options: {
    scales: {
      yAxes: [{
        stacked: true
      }]
    }
  }
});