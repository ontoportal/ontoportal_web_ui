
/**
 * To show/hide the simple metadata div
 */
function toggleDiv(divId)
{
  var e = document.getElementById(divId + "Div");
  if (e.style.display == 'block') {
    e.style.display = 'none';
    document.getElementById(divId + "Btn").classList.remove("active");
  } else {
    e.style.display = 'block';
    document.getElementById(divId + "Btn").classList.add("active");
  }
}

var chartTooltipLocked = false;

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
            "pieOuterRadius": "50%"
        },
        "data": {
            "sortOrder": "value-desc",
            "content": json
        },
        callbacks: {
          onMouseoverSegment: function (d) {
            if (chartTooltipLocked == false) {
              d3.select("#chartTooltip")
                .style("left", d3.event.pageX + "px")
                .style("top", d3.event.pageY + "px")
                .style("opacity", 1)
                .style("z-index", 1)
              d3.select("#chartTooltipValue")
                .text(d.data.uri);
              $("#chartTooltip").show();
            }
          },
          onClickSegment: function(d) {
            //dbIds: d.expanded? [] : d.data.dbIds
            var wasLocked = chartTooltipLocked
            if (d.expanded) {
              dbIds = []
              chartTooltipLocked = false;
            } else {
              dbIds = d.data.dbIds
              chartTooltipLocked = true;
            }

            if (wasLocked == true) {
              d3.select("#chartTooltip")
                .style("left", d3.event.pageX + "px")
                .style("top", d3.event.pageY + "px")
                .style("opacity", 1)
              d3.select("#chartTooltipValue")
                .text(d.data.uri);
              $("#chartTooltip").show();
            }
          },
          onMouseoutSegment: function(info) {
            //$("#chartTooltip").hide(); this avoid us to mouseover tooltip text
          }
        },
        "labels": {
            "truncation": {
              "enabled": true,
              "truncateLength": 40
            },
            "outer": {
                "pieDistance": 15
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

var formalityPie = createPie("formalityPieChartDiv", formalityPieJson, "Ontologies formality levels", "Formality level of the ontologies");

var prefLabelPie = createPie("prefLabelPropertyPieChartDiv", prefLabelPieJson, "Ontologies prefLabel properties", "prefLabel property URIs used for OWL ontologies");

var synonymPie = createPie("synonymPropertyPieChartDiv", synonymPieJson, "Ontologies synonym properties", "synonym property URIs used for OWL ontologies");

var definitionPie = createPie("definitionPropertyPieChartDiv", definitionPieJson, "Ontologies definition properties", "definition property URIs used for OWL ontologies");

var authorPie = createPie("authorPropertyPieChartDiv", authorPieJson, "Ontologies author properties", "author property URIs used for OWL ontologies");

// Generate the people tag cloud (from all contributors attributes)
$(function() {
  // When DOM is ready, select the container element and call the jQCloud method, passing the array of words as the first argument.
  $("#peopleCloudChart").jQCloud(peopleCountJsonCloud);
});

// Generate the organization tag cloud (from fundedBy, endorsedBy...), don't show if less than 5 words
$(function() {
  // When DOM is ready, select the container element and call the jQCloud method, passing the array of words as the first argument.
  if (Object.keys(orgCountJsonCloud).length > 1) {
    $("#orgCloudDiv").show();
    $("#orgCloudChart").jQCloud(orgCountJsonCloud);
  }
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

var sizeSlicesContext = document.getElementById("sizeSlicesCanvas").getContext("2d");
var sizeSlicesChart = new Chart(sizeSlicesContext, {
  type: 'bar',
  data: sizeSlicesChartJson,
  options: {
    scales: {
      yAxes: [{
        stacked: true
      }]
    }
  }
});


/**
 * Build the network of properties around an entity. Il utilise la div "ontologyNetwork"
 * @param {type} ontology
 * @param {type} entity
 * @returns {undefined}
 */
/*function buildNetwork(ontology, entity, selectedLang, ontologies) {
  // create an array with nodes
  var label = getEntityLabelLang(entity, selectedLang);
  var nodes = new vis.DataSet([
    {id: 1, label: label, color: '#FB7E81'}
  ]);
  // create an array with edges
  var edges = new vis.DataSet();
  var propertyCount = 2; // init at 2 since the entity is 1

  var orderedEntities = {};
  // Iterate over the different properties (predicates) of an entity
  // To get properties values grouped by property
  Object.keys(entity).sort().forEach(function (key) {
    if (key !== "id" && key !== "label" && key !== "$$hashKey") {
      orderedEntities[key] = null;
      // Iterate over the different values of the object of a predicate (the same property can point to different objects)
      for (var valuesObject in entity[key]) {
        if (typeof entity[key][valuesObject]["value"] !== "undefined") {
          // If it is a literal then we concatenate them
          if (orderedEntities[key] === null) {
            orderedEntities[key] = entity[key][valuesObject]["value"];
          } else {
            // Limit the size of the object
            if (orderedEntities[key].length < 70) {
              orderedEntities[key] = orderedEntities[key] + " \n" + entity[key][valuesObject]["value"];
            }
          }
        }
      }
    }
  });
  var nodeIds = {};
  // Add each property and its value to the network
  for (var attr in orderedEntities) {
    // Don't create a new node if node exist already, just add a new edge
    if (nodeIds[orderedEntities[attr]] != null) {
      edges.add([
        {from: 1, to: nodeIds[orderedEntities[attr]], label: attr, font: {align: 'horizontal'}}
      ]);
      var getLinkedProperties = false;
    } else {
      nodes.add([
        {id: propertyCount, label: orderedEntities[attr]}
      ]);
      var getLinkedProperties = true;
      nodeIds[orderedEntities[attr]] = propertyCount;
      if (entity[attr][0]["prefixedPredicate"] !== null) {
        edges.add([
          {from: 1, to: propertyCount, label: entity[attr][0]["prefixedPredicate"], font: {align: 'horizontal'}}
        ]);
      } else {
        edges.add([
          {from: 1, to: propertyCount, label: attr, font: {align: 'horizontal'}}
        ]);
      }
      var entityCount = propertyCount;
      propertyCount++;
    }

    // If property is an URI we check if it has properties in our ontology
    if (orderedEntities[attr] != null && orderedEntities[attr].startsWith("http")) {
      if (ontology === "target") {
        var ontoNumber = "ont2";
      } else if (ontology === "source") {
        var ontoNumber = "ont1";
      }
      //console.log(ontologies);

      // Get the entity linked to the mapped concept from the ontology:
      var linkedEntity = ontologies[ontoNumber]['entities'][orderedEntities[attr]];
      var linkedEntityProperties = {};
      // Iterate over the different properties (predicates) of an entity
      // To get properties values grouped by property
      if (linkedEntity != null && getLinkedProperties === true) {
        Object.keys(linkedEntity).sort().forEach(function (key) {
          if (key !== "id" && key !== "label" && key !== "$$hashKey") {
            linkedEntityProperties[key] = null;
            // Iterate over the different values of the object of a predicate (the same property can point to different objects)
            for (var valuesObject in linkedEntity[key]) {
              if (typeof linkedEntity[key][valuesObject]["value"] !== "undefined") {
                // If it is a literal then we concatenate them
                if (linkedEntityProperties[key] === null) {
                  linkedEntityProperties[key] = linkedEntity[key][valuesObject]["value"];
                } else {
                  // Limit the size of the object
                  if (linkedEntityProperties[key].length < 70) {
                    linkedEntityProperties[key] = linkedEntityProperties[key] + " \n" + linkedEntity[key][valuesObject]["value"];
                  }
                }
              }
            }
          }
        });
        // Add each property and its value to the network
        for (var linkedAttr in linkedEntityProperties) {

          // Don't create a new node if node exist already, just add a new edge
          if (nodeIds[linkedEntityProperties[linkedAttr]] != null) {
            var nodeNumber = nodeIds[linkedEntityProperties[linkedAttr]];
          } else {
            var nodeNumber = propertyCount;
            nodes.add([
              {id: nodeNumber, label: linkedEntityProperties[linkedAttr]}
            ]);
            nodeIds[linkedEntityProperties[linkedAttr]] = propertyCount;
            propertyCount++;
          }

          // Create edge with prefixed predicate when possible
          if (entity[linkedAttr] != null && entity[linkedAttr][0]["prefixedPredicate"] !== null) {
            edges.add([
              {from: entityCount, to: nodeNumber, label: entity[linkedAttr][0]["prefixedPredicate"], font: {align: 'horizontal'}}
            ]);
          } else {
            edges.add([
              {from: entityCount, to: nodeNumber, label: linkedAttr, font: {align: 'horizontal'}}
            ]);
          }
        }
      }
    }
  }
  // create a network
  var container = document.getElementById("ontologyNetwork");
  // provide the data in the vis format
  var data = {
    nodes: nodes,
    edges: edges
  };
  // Get height of div
  var networkHeight = document.getElementById(ontology + "Section").clientHeight.toString();
  var options = {
    autoResize: true,
    height: networkHeight,
    physics: {
      enabled: true,
      /*barnesHut: {
       avoidOverlap: 0.5
       },
      hierarchicalRepulsion: {
        centralGravity: 0.0,
        springLength: 400,
        springConstant: 0.01,
        damping: 0.09,
        nodeDistance: 50
      },
      solver: 'hierarchicalRepulsion'
    }
  };

  // initialize your network!
  //console.log(data);
  var network = new vis.Network(container, data, options);
  network.fit();
}*/



// Hide tooltip when click outside of pie chart div
$(document).mouseup(function (e)
{
  var container = $("#pieChartDiv");
  if (!container.is(e.target) // if the target of the click isn't the container...
    && container.has(e.target).length === 0) // ... nor a descendant of the container
  {
    chartTooltipLocked = false;
    $("#chartTooltip").hide();
  }
});

// Hide more properties pie div on load to let the pie lib the time to get the parent div size (to size the pie chart)
window.onload = function() {
  $("#propertiesDiv").hide();
};