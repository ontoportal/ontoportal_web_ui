
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

/* EN NOIR ET GRIS

var color = d3.scale.linear()
  .domain([0,1,2,3,4,5,6,10,15,20,100])
  .range(["#ddd", "#ccc", "#bbb", "#aaa", "#999", "#888", "#777", "#666", "#555", "#444", "#333", "#222"]);

d3.layout.cloud().size([800, 300])
  .words(peopleCountJsonCloud)
  .rotate(0)
  .fontSize(function(d) { return d.size; })
  .on("end", draw)
  .start();

function draw(words) {
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
}*/

// Super grand : https://bl.ocks.org/blockspring/847a40e23f68d6d7e8b5#cloud.js
// j'ai mis cloud.js dans d3.layout.cloud.js (mais ça semble bien marcher avec l'autre version aussi
//var text_string = "Of course that’s your contention. You’re a first year grad student. You just got finished readin’ some Marxian historian, Pete Garrison probably. You’re gonna be convinced of that ’til next month when you get to James Lemon and then you’re gonna be talkin’ about how the economies of Virginia and Pennsylvania were entrepreneurial and capitalist way back in 1740. That’s gonna last until next year. You’re gonna be in here regurgitating Gordon Wood, talkin’ about, you know, the Pre-Revolutionary utopia and the capital-forming effects of military mobilization… ‘Wood drastically underestimates the impact of social distinctions predicated upon wealth, especially inherited wealth.’ You got that from Vickers, Work in Essex County, page 98, right? Yeah, I read that, too. Were you gonna plagiarize the whole thing for us? Do you have any thoughts of your own on this matter? Or do you, is that your thing? You come into a bar. You read some obscure passage and then pretend, you pawn it off as your own, as your own idea just to impress some girls and embarrass my friend? See, the sad thing about a guy like you is in 50 years, you’re gonna start doin’ some thinkin’ on your own and you’re gonna come up with the fact that there are two certainties in life. One: don’t do that. And two: you dropped a hundred and fifty grand on a fuckin’ education you coulda got for a dollar fifty in late charges at the public library.";

/*drawWordCloud();

function drawWordCloud(){

  var common = "poop,i,me,my,myself,we,us,our,ours,ourselves,you,your,yours,yourself,yourselves,he,him,his,himself,she,her,hers,herself,it,its,itself,they,them,their,theirs,themselves,what,which,who,whom,whose,this,that,these,those,am,is,are,was,were,be,been,being,have,has,had,having,do,does,did,doing,will,would,should,can,could,ought,i'm,you're,he's,she's,it's,we're,they're,i've,you've,we've,they've,i'd,you'd,he'd,she'd,we'd,they'd,i'll,you'll,he'll,she'll,we'll,they'll,isn't,aren't,wasn't,weren't,hasn't,haven't,hadn't,doesn't,don't,didn't,won't,wouldn't,shan't,shouldn't,can't,cannot,couldn't,mustn't,let's,that's,who's,what's,here's,there's,when's,where's,why's,how's,a,an,the,and,but,if,or,because,as,until,while,of,at,by,for,with,about,against,between,into,through,during,before,after,above,below,to,from,up,upon,down,in,out,on,off,over,under,again,further,then,once,here,there,when,where,why,how,all,any,both,each,few,more,most,other,some,such,no,nor,not,only,own,same,so,than,too,very,say,says,said,shall";
  var word_count = {};

  var words = text_string.split(/[ '\-\(\)\*":;\[\]|{},.!?]+/);
  if (words.length == 1){
    word_count[words[0]] = 1;
  } else {
    words.forEach(function(word){
      var word = word.toLowerCase();
      if (word != "" && common.indexOf(word)==-1 && word.length>1){
        if (word_count[word]){
          word_count[word]++;
        } else {
          word_count[word] = 1;
        }
      }
    })
  }

  var svg_location = "#cloudChart";
  var width = $(document).width();
  var height = $(document).height();

  var fill = d3.scale.category20();

  var word_entries = d3.entries(peopleCountJsonCloud);

  var xScale = d3.scale.linear()
    .domain([0, d3.max(word_entries, function(d) {
      return d.value;
    })
    ])
    .range([10,100]);

  d3.layout.cloud().size([1500, 500])
    .timeInterval(20)
    .words(word_entries)
    .fontSize(function(d) { return xScale(+d.value); })
    .text(function(d) { return d.key; })
    .rotate(function() { return ~~(Math.random() * 2); })
    .font("Impact")
    .on("end", draw)
    .start();

  function draw(words) {
    d3.select(svg_location).append("svg")
      .attr("width", 1500)
      .attr("height", height)
      .append("g")
      .attr("transform", "translate(" + [width >> 1, height >> 1] + ")")
      .selectAll("text")
      .data(words)
      .enter().append("text")
      .style("font-size", function(d) { return xScale(d.value) + "px"; })
      .style("font-family", "Impact")
      .style("fill", function(d, i) { return fill(i); })
      .attr("text-anchor", "middle")
      .attr("transform", function(d) {
        return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
      })
      .text(function(d) { return d.key; });
  }

  d3.layout.cloud().stop();
}*/

$(function() {
  // When DOM is ready, select the container element and call the jQCloud method, passing the array of words as the first argument.
  console.log("yeee");
  console.log(peopleCountJsonCloud);
  $("#cloudChart").jQCloud(peopleCountJsonCloud);
});

/* MARCHE BIEN
var fill = d3.scale.category20();
d3.layout.cloud().size([300, 300])
  .words(peopleCountJsonCloud)
  .padding(5)
  .rotate(function() { return 0; })
  .text(function(d) { return d.text; })
  .font("Impact")
  .fontSize(function(d) { return d.size; })
  .on("end", draw)
  .start();
function draw(words) {
  d3.select("#cloudChart").append("svg")
    .attr("width", 300)
    .attr("height", 300)
    .append("g")
    .attr("transform", "translate(150,150)")
    .selectAll("text")
    .data(words)
    .enter().append("text")
    .style("font-size", function(d) { return d.size + "em"; })
    .style("font-family", "Impact")
    .style("fill", function(d, i) { return fill(i); })
    .attr("text-anchor", "middle")
    .attr("transform", function(d) {
      return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
    })
    .text(function(d) { return d.text; });
};
/*
var fill = d3.scale.category20();
var data = [{word:"Hello",weight:20},{word:"World",weight:10},{word:"Normally",weight:25},{word:"You",weight:15},{word:"Want",weight:30},{word:"More",weight:12},{word:"Words",weight:8},{word:"But",weight:18},{word:"Who",weight:22},{word:"Cares",weight:27}];

d3.layout.cloud().size([500, 500])
  .words(peopleCountJsonCloud.map(function(d) {
    return {text: d.word, size: d.weight};
  }))
  .padding(5)
  .rotate(function() { return ~~(Math.random() * 2); })
  .font("Impact")
  .fontSize(function(d) { return d.size; })
  .on("end", draw)
  .start();

function draw(words) {
  d3.select("#cloudChart").append("svg")
    .attr("width", 500)
    .attr("height", 500)
    .append("g")
    .attr("transform", "translate(150,150)")
    .selectAll("text")
    .data(words)
    .enter().append("text")
    .style("font-size", function(d) { return d.size + "px"; })
    .style("font-family", "Impact")
    .style("fill", function(d, i) { return fill(i); })
    .attr("text-anchor", "middle")
    .attr("transform", function(d) {
      return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
    })
    .text(function(d) { return d.text; });
}

function drawUpdate(words){
  //alert(JSON.stringify(words));   //shows me the added data

  d3.select("body").selectAll("text")
    .data(words.map(function(d) {
      return {text: d.word, size: d.weight};
    }))
    .style("font-size", function(d) { return d.size + "px"; })
    .style("font-family", "Impact")
    .style("fill", function(d, i) { return fill(i); })
    .attr("text-anchor", "middle")
    .text(function(d) { return d.text; });
}

setInterval(function () {
  var d_new = data;
  d_new.push({word: "Mappy",weight:35});
  drawUpdate(d_new);
}, 1500);



// Generate the word cloud (https://github.com/jasondavies/d3-cloud)
/*var fill = d3.scale.category20();

d3.layout.cloud().size([500, 500])
  .words([
    "Hello", "world", "normally", "you", "want", "more", "words",
    "than", "this"].map(function(d) {
    return {text: d, size: 10 + Math.random() * 90, test: "haha"};
  }))
  .padding(5)
  .rotate(function() { return ~~(Math.random() * 2) * 90; })
  .font("Impact")
  .fontSize(function(d) { return d.size; })
  .on("end", draw)
  .start();

//layout.start();

function draw(words) {
  d3.select("#cloudChart").append("svg")
    .attr("width", 500)
    .attr("height", 500)
    .append("g")
    .attr("transform", "translate(500,500)")
    .selectAll("text")
    .data(words)
    .enter().append("text")
    .style("font-size", function(d) { return d.size + "px"; })
    .style("font-family", "Impact")
    .style("fill", function(d, i) { return fill(i); })
    .attr("text-anchor", "middle")
    .attr("transform", function(d) {
      return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
    })
    .text(function(d) { return d.text; });
}*/

/*
d3.layout.cloud().size([800, 300])
    .words(peopleCountJsonCloud)
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
        // Get color from the color key in the JSON
        .style("fill", function(d, i) { return d.color; })
        .attr("transform", function(d) {
            return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
        })
        .text(function(d) { return d.text; });
}*/


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