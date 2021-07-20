class FairScoreChartContainer{
    constructor(fairChartsContainerId , charts) {
        this.fairChartsContainer = jQuery("#"+fairChartsContainerId)
        this.fairScoreSpan = jQuery("#fair-score")
        this.fairNormalizedScoreSpan = jQuery("#fair-normalized-score")
        this.fairSpinner = jQuery("<div id='fair-spinner-container' class='w-100 text-center'> <div class='spinner-grow'></div> </div>")
        this.fairChartsContainer.before(this.fairSpinner)
        this.charts = charts
    }


    ajaxCall(ontologies){
        return new Promise( (resolve  ,reject) => {
            $.getJSON( "/ajax/fair_score/json/?ontologies="+ontologies, (data) => {
                if(data) {
                    resolve(data)
                }else {
                    reject("error")
                }
            })
        })
    }
    getFairScoreData(ontologies) {
        if(this.fairChartsContainer){
            this.showLoader();
            this.ajaxCall(ontologies).then(data => {
                this.hideLoader()
                this.charts.forEach( x => x.setFairScoreData(data))
                if(this.fairScoreSpan)
                    this.fairScoreSpan.html(data.score)

                if(this.fairNormalizedScoreSpan)
                    this.fairNormalizedScoreSpan.html('('+data.normalizedScore+"%)")
            })
        }


    }
    showLoader(){
        console.log("show loader")
        this.fairChartsContainer.hide()
        this.fairSpinner.show()
    }
    hideLoader(){
        this.fairSpinner.hide()
        this.fairChartsContainer.show()
    }

}
class FairScoreChart{
    constructor(fairCanvasId , dataField) {
        this.dataField = dataField
        this.fairScoreChartCanvas =  jQuery("#"+fairCanvasId)
        this.chart= null
    }

    setFairScoreData(data){
        if(this.fairScoreChartCanvas){
            Object.entries(data[this.dataField]).forEach( ([key, value]) => this.fairScoreChartCanvas.data(key , value))
            this.fairScoreChartCanvas.data("resourceCount" , data["resourceCount"])
            if(this.chart === null)
                this.chart = this.initChart()
            else {
                this.chart.data.datasets = this.getFairScoreDataSet()
                this.chart.update()
            }
        }

    }

    getFairScoreDataSet(){
        return []
    }

    initChart(){
        return new Chart(this.fairScoreChartCanvas , {})
    }

}
class FairScorePrincipleBar extends  FairScoreChart{

    constructor(fairCanvasId) {
        super(fairCanvasId , 'principles');
    }
    initChart() {
        const labels = this.fairScoreChartCanvas.data('labels')
        const data = {
            labels: labels,
            datasets: this.getFairScoreDataSet()
        };
        const config = {
            type: 'horizontalBar',
            data: data,
            options: {
                title: {
                    display: false,
                    text: 'FAIRness Scores'
                },
                elements: {
                    bar: {
                        borderWidth: 2,
                    }
                },
                indexAxis: 'y',
                legend: {
                    display: true
                },
                scales: {
                    xAxes: [{
                        stacked: true,
                        ticks: {
                            beginAtZero: true
                        }
                    }],
                    yAxes: [{
                        stacked: true,
                        ticks: {
                            beginAtZero: true
                        }
                    }]
                }
            }
        }

        return new Chart(this.fairScoreChartCanvas, config);
    }
    getFairScoreDataSet(){
        const scores = this.fairScoreChartCanvas.data('scores')
        const maxCredits = this.fairScoreChartCanvas.data('maxCredits')
        const portalMaxCredits = this.fairScoreChartCanvas.data('portalMaxCredits')
        return [
            {
                label: 'Obtained score',
                data: scores,
                fill: true,
                backgroundColor: 'rgba(102, 187, 106, 0.2)',
                borderColor: 'rgba(102, 187, 106, 1)',
                pointBorderColor: 'rgba(102, 187, 106, 1)',
                pointBackgroundColor: 'rgba(102, 187, 106, 1)'
            },
            {
                label: 'Not obtained score',
                data: portalMaxCredits.map((x,i) => {
                    return Math.round((x  / maxCredits[i]) * 100) - scores[i]
                }),
                fill: true,
                backgroundColor: 'rgba(251, 192, 45, 0.2)',
                borderColor: 'rgba(251, 192, 45, 1)',
                pointBorderColor: 'rgba(251, 192, 45, 1)',
                pointBackgroundColor: 'rgba(251, 192, 45, 1)'
            },
            {
                label: 'N/A score',
                data: maxCredits.map((x,i) => {
                    return Math.round(((x -  portalMaxCredits[i]) / maxCredits[i]) * 100)
                }),
                fill: true,
                backgroundColor: 'rgba(176, 190, 197, 0.2)',
                borderColor: 'rgba(176, 190, 197, 1)',
                pointBorderColor: 'rgba(176, 190, 197, 1)',
                pointBackgroundColor: 'rgba(176, 190, 197, 1)'
            }
        ]
    }
}
class FairScoreCriteriaRadar extends FairScoreChart{

    constructor(fairCanvasId) {
        super( fairCanvasId , 'criteria');
    }

    customTooltips(){
        return function (tooltipModel)  {
            // Tooltip Element
            let tooltipEl = document.getElementById('chartjs-tooltip');
            let canvas = jQuery(this._chart.canvas)
            let descriptions = canvas.data("descriptions")
            // Create element on first render
            if (!tooltipEl) {
                tooltipEl = document.createElement('div');
                tooltipEl.id = 'chartjs-tooltip';
                tooltipEl.innerHTML = '<table style="max-width: 250px"></table>';
                document.body.appendChild(tooltipEl);
            }

            // Hide if no tooltip
            if (tooltipModel.opacity === 0) {
                tooltipEl.style.opacity = 0;
                return;
            }

            // Set caret Position
            tooltipEl.classList.remove('above', 'below', 'no-transform');
            if (tooltipModel.yAlign) {
                tooltipEl.classList.add(tooltipModel.yAlign);
            } else {
                tooltipEl.classList.add('no-transform');
            }

            function getBody(bodyItem) {
                return bodyItem.lines;
            }

            // Set Text
            if (tooltipModel.body) {
                let titleLines = tooltipModel.title || [];
                let bodyLines = tooltipModel.body.map(getBody);

                let innerHtml = '<thead>';

                titleLines.forEach(function(title ,index) {
                    innerHtml += '<tr><th>' + title + ' : '+  descriptions[tooltipModel.dataPoints[0].index] + '</th></tr>';
                });
                innerHtml += '</thead><tbody>';

                bodyLines.forEach(function(body, i) {
                    let colors = tooltipModel.labelColors[i];
                    let style = 'background:' + colors.backgroundColor;
                    style += '; border-color:' + colors.borderColor;
                    style += '; border-width: 2px;';
                    style += '; font-size: 12px;';
                    innerHtml += '<tr><td class="badge" style="'+ style+'" >' + body + '</td></tr>';
                });
                innerHtml += '</tbody>';

                let tableRoot = tooltipEl.querySelector('table');
                tableRoot.innerHTML = innerHtml;
            }

            // `this` will be the overall tooltip
            let position = this._chart.canvas.getBoundingClientRect();

            // Display, position, and set styles for font
            tooltipEl.style.background = 'rgba(0, 0, 0, 0.7)';
            tooltipEl.style.borderRadius = '3px';
            tooltipEl.style.color = 'white';
            tooltipEl.style.opacity = 1;
            tooltipEl.style.position = 'absolute';
            tooltipEl.style.left = position.left + window.pageXOffset + tooltipModel.caretX + 'px';
            tooltipEl.style.top = position.top + window.pageYOffset + tooltipModel.caretY + 'px';
            tooltipEl.style.fontFamily = tooltipModel._bodyFontFamily;
            tooltipEl.style.fontSize = tooltipModel.bodyFontSize + 'px';
            tooltipEl.style.fontStyle = tooltipModel._bodyFontStyle;
            tooltipEl.style.padding = tooltipModel.yPadding + 'px ' + tooltipModel.xPadding + 'px';
            tooltipEl.style.pointerEvents = 'none';
        }
    }

    initChart() {
        const labels = this.fairScoreChartCanvas.data('labels')

        const data = {
            labels: labels,
            datasets: this.getFairScoreDataSet()
        };
        const config = {
            type: 'radar',
            data: data,
            options: {
                title: {
                    display: false,
                    text: 'FAIRness Wheel'
                },
                legend: {
                    display: false
                },
                elements: {
                    line: {
                        borderWidth: 3
                    }
                },
                tooltips: {
                    enabled: false,
                    custom: this.customTooltips(),
                    callbacks: {
                        label: function (tooltipItem, data) {
                            return data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                        },

                    }
                }
            }
        }

        return new Chart(this.fairScoreChartCanvas, config);
    }

    getFairScoreDataSet() {
        const scores = this.fairScoreChartCanvas.data('scores')
       return [
            {
                label: 'Fair score',
                data: scores,
                fill: true,
                backgroundColor: 'rgba(151, 187, 205, 0.2)',
                borderColor: 'rgba(151, 187, 205, 1)',
                pointBorderColor: 'rgba(151, 187, 205, 1)',
                pointBackgroundColor: 'rgba(151, 187, 205, 1)'
            }
        ]
    }



}
class FairScoreCriteriaBar extends  FairScoreChart{
    constructor(fairCanvasId) {
        super(fairCanvasId , 'criteria');
        this.questions = []
    }
    customTooltips(){
        return function (tooltipModel)  {
            let tooltipContainer = document.getElementById('chartjs-tooltip-container')
            // Tooltip Element
            let tooltipEl = document.getElementById('chartjs-tooltip')
            let canvas = jQuery(this._chart.canvas)
            let questions = canvas.data("questions")
            let descriptions = canvas.data("descriptions")
            let resourceCount  = canvas.data("resourceCount")

            // Create element on first render
            if (!tooltipEl) {
                tooltipEl = document.createElement('div');
                tooltipEl.id = 'chartjs-tooltip';
                tooltipEl.innerHTML = '<div class="card"></div>';
                tooltipContainer.appendChild(tooltipEl);
            }

            // Hide if no tooltip
            if (tooltipModel.opacity === 0) {
                tooltipEl.style.opacity = 1;
                return;
            }

            // Set caret Position
            tooltipEl.classList.remove('above', 'below', 'no-transform');
            if (tooltipModel.yAlign) {
                tooltipEl.classList.add(tooltipModel.yAlign);
            } else {
                tooltipEl.classList.add('no-transform');
            }

            function getBody(bodyItem) {
                return bodyItem.lines;
            }

            // Set Text
            if (tooltipModel.body) {
                let titleLines = tooltipModel.title || [];
                let bodyLines = tooltipModel.body.map(getBody);

                let innerHtml = '<div class="card-body" style="text-align: start">';

                titleLines.forEach(function(title ,index) {
                    innerHtml += '<h5 class="card-title">' + title + ' : '+  descriptions[tooltipModel.dataPoints[0].index] + '</h5>';
                });

                innerHtml += "<div class='d-flex flex-wrap'>"
                bodyLines.forEach(function(body, i) {
                    let colors = tooltipModel.labelColors[i];
                    let style = 'background:' + colors.backgroundColor;
                    style += '; border-color:' + colors.borderColor;
                    style += '; border-width: 2px';
                    innerHtml += '<span class="btn card-subtitle m-2 text-muted" style="'+ style+'">' + body + '</span>';
                });

                innerHtml+='</div> <ul class="list-group list-group-flush" style="font-size: medium">'


                for (const [key, value] of Object.entries(questions[tooltipModel.dataPoints[0].index])) {
                    let count = (value.state.success + value.state.average)
                    innerHtml+='<li class="list-group-item">'+
                        '<span class="badge badge-success ">'+Math.round((count / resourceCount) * 100)+'% ('+count+') </span>'
                        +' responded successfully to '+
                        '<span class="font-italic">"'+ value.question+' "</span></li>'
                }
                innerHtml += '</ul></div>';

                let tableRoot = tooltipEl.querySelector('div');
                tableRoot.innerHTML = innerHtml;
            }

            // `this` will be the overall tooltip
            let position = this._chart.canvas.getBoundingClientRect()
            let topOffset = tooltipModel.caretY - (tooltipEl.clientHeight / 2)


            if (topOffset  <= 0)
                topOffset = 0
           else if( (topOffset + tooltipEl.clientHeight) >=  position.height)
                topOffset = position.height - tooltipEl.clientHeight

            // Display, position, and set styles for font
            tooltipEl.style.opacity = 1;
            tooltipEl.style.position = 'absolute';
            tooltipEl.style.top = topOffset +'px';
            //tooltipEl.style.fontFamily = tooltipModel._bodyFontFamily;
            tooltipEl.style.fontSize = tooltipModel.bodyFontSize + 'px';
            tooltipEl.style.fontStyle = tooltipModel._bodyFontStyle;
            tooltipEl.style.padding = tooltipModel.yPadding + 'px ' + tooltipModel.xPadding + 'px';
            tooltipEl.style.pointerEvents = 'none';
        }
    }
    initChart() {
        const labels = this.fairScoreChartCanvas.data('labels')
        const data = {
            labels: labels,
            datasets: this.getFairScoreDataSet()
        };
        const config = {
            type: 'horizontalBar',
            data: data,
            options: {
                title: {
                    display: false,
                    text: 'FAIRness Scores'
                },
                elements: {
                    bar: {
                        borderWidth: 2,
                    }
                },
                indexAxis: 'y',
                legend: {
                    display: true
                },
                scales: {
                    xAxes: [{
                        stacked: true,
                        ticks: {
                            beginAtZero: true,

                        }
                    }],
                    yAxes: [{
                        stacked: true,
                        ticks: {
                            beginAtZero: true,

                        }
                    }]
                },
                tooltips: {
                    enabled: false,
                    mode: 'index',
                    position: 'nearest',
                    intersect: false,
                    custom: this.customTooltips()
                }

            }
        }

        return new Chart(this.fairScoreChartCanvas, config);
    }
    getFairScoreDataSet(){
        const scores = this.fairScoreChartCanvas.data('scores')
        const maxCredits = this.fairScoreChartCanvas.data('maxCredits')
        const portalMaxCredits = this.fairScoreChartCanvas.data('portalMaxCredits')
        return [
            {
                label: 'Obtained score',
                data: scores,
                fill: true,
                backgroundColor: 'rgba(102, 187, 106, 0.2)',
                borderColor: 'rgba(102, 187, 106, 1)',
                pointBorderColor: 'rgba(102, 187, 106, 1)',
                pointBackgroundColor: 'rgba(102, 187, 106, 1)'
            },
            {
                label: 'Not obtained score',
                data: portalMaxCredits.map((x,i) => {
                    return Math.round((x  / maxCredits[i]) * 100) - scores[i]
                }),
                fill: true,
                backgroundColor: 'rgba(251, 192, 45, 0.2)',
                borderColor: 'rgba(251, 192, 45, 1)',
                pointBorderColor: 'rgba(251, 192, 45, 1)',
                pointBackgroundColor: 'rgba(251, 192, 45, 1)',
            },
            {
                label: 'N/A score',
                data: maxCredits.map((x,i) => {
                    return Math.round(((x -  portalMaxCredits[i]) / maxCredits[i]) * 100)
                }),
                fill: true,
                backgroundColor: 'rgba(176, 190, 197, 0.2)',
                borderColor: 'rgba(176, 190, 197, 1)',
                pointBorderColor: 'rgba(176, 190, 197, 1)',
                pointBackgroundColor: 'rgba(176, 190, 197, 1)'
            }
        ]
    }
    setFairScoreData(data) {
        super.setFairScoreData(data);
        if(this.chart){
            this.showFirstToolTip()
        }
    }

    showFirstToolTip(){
        let meta = this.chart.getDatasetMeta(0),
            rect = this.chart.canvas.getBoundingClientRect(),
            point = meta.data[0].getCenterPoint(),
            evt = new MouseEvent('mousemove', {
                clientX: rect.left + point.x,
                clientY: rect.top + point.y
            }),
            node = this.chart.canvas;
        node.dispatchEvent(evt);
    }
}


/*
    For landscape
 */
jQuery('#landscape_fair_statistics').ready(()=> {
    let fairCriteriaBars = new FairScoreCriteriaBar('ont-fair-scores-criteria-bars-canvas')
    let fairContainer = new FairScoreChartContainer('fair-score-charts-container' , [fairCriteriaBars])
    let ontologies = jQuery("#ontology_ontologyId");

    fairContainer.getFairScoreData("all")
    ontologies.change( (e) => {
        console.log( ontologies.val())
        if(ontologies.val() !== null){
            fairContainer.getFairScoreData(ontologies.val().join(','))
        } else if(ontologies.val() === null){
            fairContainer.getFairScoreData("all")
        }
        e.preventDefault()
    })
    return false
})



/*
    For the home and summary
 */
jQuery('.statistics_container').ready( function (e) {

    let fairScoreBar = new FairScorePrincipleBar( 'ont-fair-scores-canvas')
    let fairScoreRadar = new FairScoreCriteriaRadar(  'ont-fair-criteria-scores-canvas')
    let fairContainer = new FairScoreChartContainer('fair-score-charts-container' , [   fairScoreRadar , fairScoreBar])
    let ontologies = jQuery("#ontology_ontologyId");

    fairContainer.getFairScoreData("all")
    ontologies.change( (e) => {
            console.log("ontologies changed")
            console.log( ontologies.val())
            if(ontologies.val() !== null){
                fairContainer.getFairScoreData(ontologies.val().join(','))
            } else if(ontologies.val() === null){
                fairContainer.getFairScoreData("all")
            }
        e.preventDefault()
    })
    return false
})


