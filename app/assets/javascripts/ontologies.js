/* Ontology viewing */
jQuery('#ont_summary_content ').ready(function (){
    showFairCriteriaScoreChart()
    showFairScoreChart()
    showVisitsChat()
    console.log("changed")
})

/*jQuery('.ontologies.show').ready(function () {
    showFairCriteriaScoreChart()
    showFairScoreChart()
    showVisitsChat()
});
*/
/* Ontology creation & editing */

function hideAllRestrictions() {
    jQuery(".viewing_restriction_disabled").attr("disabled", true);
    jQuery("div.viewing_restriction_types").addClass("hidden");
}

function showRestrictionPrivate() {
    jQuery("#ontology_acl").removeAttr("disabled");
    jQuery("#viewingRestrictionsPrivate").removeClass("hidden");
}

function showRestrictionLicensed() {
    jQuery("#ontology_licenseInformation").removeAttr("disabled");
    jQuery("#viewingRestrictionsLicensed").removeClass("hidden");
}

jQuery(document).ready(function () {

    // Wire up options for restriction how an ontology is viewed
    jQuery("#ontology_viewingRestriction").change(function () {
        var select = jQuery(this);
        if (select.val() == "private") {
            hideAllRestrictions()
            showRestrictionPrivate();
        } else if (select.val() == "licensed") {
            hideAllRestrictions();
            showRestrictionLicensed();
        } else if (select.val() == "public") {
            hideAllRestrictions();
        }
    });

    // Make sure you can see the account select if the select list has private selected
    if (jQuery("#ontology_viewingRestriction").val() == "private") {
        showRestrictionPrivate();
    } else if (jQuery("#ontology_viewingRestriction").val() == "licensed") {
        showRestrictionLicensed();
    }

    jQuery("#ontology_isView").live("click", function () {
        console.log(jQuery("#ontology_isView").is(":checked"))
        if (jQuery("#ontology_isView").is(":checked")) {
            jQuery("#ontology_viewOf").removeAttr('disabled').trigger("chosen:updated");
        } else {
            jQuery("#ontology_viewOf").attr('disabled', true).trigger("chosen:updated");
        }
    });

    // Wire up chosen selectors
    jQuery("#ontology_administeredBy").chosen({width: '100%'});
    jQuery("#ontology_acl").chosen({width: '100%'});
    jQuery("#ontology_hasDomain").chosen({width: '100%'});

    // Make acronym upcase as you type
    jQuery("#ontology_acronym").on('input', function (e) {
        var input = $(this);
        var start = input[0].selectionStart;
        $(this).val(function (_, val) {
            return val.toUpperCase();
        });
        input[0].selectionStart = input[0].selectionEnd = start;
    });

    // Check acronym as you type
    var acronyms = jQuery("#ontology_acronym").data("acronyms");
    jQuery("#ontology_acronym").on('input', function (e) {
        var $this = $(this);
        var errors = [];
        var errorHTML = "";

        if ($this.val().match("^[^a-z^A-Z]{1}")) {
            errors.push("Acronym must start with a letter");
        }

        if ($this.val().match("[^-_0-9a-zA-Z]")) {
            errors.push("Acronym must only contain the folowing characters: -, _, letters, and numbers");
        }

        if ($this.val().match(".{17,}")) {
            errors.push("Acronym must be sixteen characters or less");
        }

        if (acronyms.indexOf($this.val()) > -1) {
            errors.push("Acronym already in use");
        }

        if (errors.length > 0) {
            errorHTML = "<li>" + errors.join("</li><li>") + "</li>";
        }

        jQuery("#acronym_errors").html(errorHTML);
    });

    jQuery("#ontologyForm").validate({
        errorClass: "ontologyFormError",
        errorElement: "div",
        rules: {
            "ontology[name]": "required",
            "ontology[acronym]": "required",
        },
        messages: {
            "ontology[name]": "Please enter a name",
            "ontology[acronym]": "Please enter an acronym",
        },
    });
});

/* charts creation */
function showFairCriteriaScoreChart() {
    const fairScoreChartCanvas = document.getElementById('ont-fair-criteria-scores-canvas');
    const data = {
        labels: JSON.parse(fairScoreChartCanvas.dataset.labels),
        datasets: [
            {
                label: 'Fair score',
                data: JSON.parse(fairScoreChartCanvas.dataset.scores),
                fill: true,
                backgroundColor: 'rgba(151, 187, 205, 0.2)',
                borderColor: 'rgba(151, 187, 205, 1)',
                pointBorderColor: 'rgba(151, 187, 205, 1)',
                pointBackgroundColor: 'rgba(151, 187, 205, 1)'
            }
        ]
    };
    const config = {
        type: 'radar',
        data: data,
        options: {
            title: {
                display: true,
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
                enabled: true,
                callbacks: {
                    label: function (tooltipItem, data) {
                        return data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                    }
                }
            }
        }
    }

    return new Chart(fairScoreChartCanvas, config);
}

function showFairScoreChart() {
    const fairScoreChartCanvas = document.getElementById('ont-fair-scores-canvas');
    const scores = JSON.parse(fairScoreChartCanvas.dataset.scores)
    const maxCredits = JSON.parse(fairScoreChartCanvas.dataset.maxcredits)
    const portalMaxCredits = JSON.parse(fairScoreChartCanvas.dataset.portalmaxcredits)

    const data = {
        labels: JSON.parse(fairScoreChartCanvas.dataset.labels),
        datasets: [
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
                backgroundColor: 'rgba(255, 111, 96, 0.2)',
                borderColor: 'rgba(255, 111, 96, 1)',
                pointBorderColor: 'rgba(255, 111, 96, 1)',
                pointBackgroundColor: 'rgba(255, 111, 96, 1)'
            }
        ]
    };
    const config = {
        type: 'horizontalBar',
        data: data,
        options: {
            title: {
                display: true,
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

    return new Chart(fairScoreChartCanvas, config);
}


function showVisitsChat(){
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
                            callback: function (value, index, values) {
                                return numberWithCommas(value);
                            }
                        }
                    }]
                },
                tooltips: {
                    displayColors: false,
                    callbacks: {
                        label: function (tooltipItem, data) {
                            return numberWithCommas(tooltipItem.yLabel);
                        }
                    }
                }
            }
        });
    }
    return ontologyVisitsChart
}
