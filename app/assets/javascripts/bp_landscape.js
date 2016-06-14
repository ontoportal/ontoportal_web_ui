// Get the data to generate the pie chart for the naturalLanguage

// Creating a pie chart using d3pie.js
var pie = new d3pie("pieChart", {
    "header": {
        "title": {
            "text": "Ontologies natural languages in BioPortal",
            "fontSize": 24,
            "font": "open sans"
        },
        "subtitle": {
            "text": "A full pie chart to show the different natural languages used in BioPortal",
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
        "canvasWidth": 590,
        "pieOuterRadius": "90%"
    },
    "data": {
        "sortOrder": "value-desc",
        "content": pieJson
    },
    "labels": {
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
});



// Generate the tag cloud
var color = d3.scale.linear()
    .domain([0,1,2,3,4,5,6,10,15,20,100])
    .range(["#ddd", "#ccc", "#bbb", "#aaa", "#999", "#888", "#777", "#666", "#555", "#444", "#333", "#222"]);

d3.layout.cloud().size([800, 300])
    .words(cloudJson)
    .rotate(0)
    .fontSize(function(d) { return d.size; })
    .on("end", draw)
    .start();

function draw(words) {
    // Add the svg tagcloud to body
    d3.select("#cloudChart").append("svg")
        .attr("width", 850)
        .attr("height", 350)
        .attr("class", "wordcloud")
        .append("g")
        // without the transform, words words would get cutoff to the left and top, they would
        // appear outside of the SVG area
        .attr("transform", "translate(320,200)")
        .selectAll("text")
        .data(words)
        .enter().append("text")
        .style("font-size", function(d) { return d.size + "px"; })
        .style("fill", function(d, i) { return color(i); })
        .attr("transform", function(d) {
            return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
        })
        .text(function(d) { return d.text; });
}