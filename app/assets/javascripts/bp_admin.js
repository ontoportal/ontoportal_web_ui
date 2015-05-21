/**
 * Created by mdorf on 3/27/15.
 */
var DUMMY_ONTOLOGY = "DUMMY_ONT";
var problemOnly = true;

function toggleShow(val) {
  problemOnly = val;
}

function millisToMinutesAndSeconds(millis) {
  var minutes = Math.floor(millis / 60000);
  var seconds = ((millis % 60000) / 1000).toFixed(0);
  return minutes + " minutes " + seconds + " seconds";
}

var AjaxAction = function(httpMethod, operation, path, params) {
  params = params || {};
  this.httpMethod = httpMethod;
  this.operation = operation;
  this.path = path;
  this.ontologies = [DUMMY_ONTOLOGY];

  if (params["ontologies"]) {
    this.ontologies = params["ontologies"].split(",");
    delete params["ontologies"];
  }
  this.params = params;
  this.confirmMsg = "Are you sure?";
};

AjaxAction.prototype.setConfirmMsg = function(msg) {
  this.confirmMsg = msg;
};

AjaxAction.prototype.clearStatusMessages = function() {
  jQuery("#progress_message").hide();
  jQuery("#success_message").hide();
  jQuery("#error_message").hide();
  jQuery("#progress_message").html("");
  jQuery("#success_message").html("");
  jQuery("#error_message").html("");
};

AjaxAction.prototype.showProgressMessage = function() {
  this.clearStatusMessages();
  var msg = "Processing " + this.operation;

  if (this.ontologies[0] !== DUMMY_ONTOLOGY) {
    msg += " for " + this.ontologies.join(", ");
  }
  jQuery("#progress_message").text(msg).html();
  jQuery("#progress_message").show();
};

AjaxAction.prototype.showStatusMessages = function(success, errors) {
  if (success.length > 0) {
    jQuery("#success_message").text(success.join(", ")).html();
    jQuery("#success_message").show();
  }

  if (errors.length > 0) {
    jQuery("#error_message").text(errors.join(", ")).html();
    jQuery("#error_message").show();
  }
};

AjaxAction.prototype._ajaxCall = function() {
  var self = this;
  var errors = [];
  var success = [];
  var promises = [];
  var status = {progress: false};
  var params = jQuery.extend(true, {}, self.params);
  self.showProgressMessage();

  // using javascript closure for passing index to asynchronous calls
  jQuery.each(self.ontologies, function(index, ontology) {
    params["ontologies"] = ontology;
    var req = jQuery.ajax({
      type: self.httpMethod,
      url: "/admin/" + self.path,
      data: params,
      dataType: "json",
      success: function(data, msg) {
        var reg = /\s*\,\s*/g;

        if (data.errors) {
          var err = data.errors.replace(reg, ',');
          errors.push.apply(errors, err.split(","));
        }

        if (data.success) {
          self.onSuccessAction(data, ontology, status);

          if (data.success) {
            var suc = data.success.replace(reg, ',');
            success.push.apply(success, suc.split(","));
          }
        }
        self.showStatusMessages(success, errors);
      },
      error: function(request, textStatus, errorThrown) {
        errors.push(request.status + ": " + errorThrown);
        self.showStatusMessages(success, errors);
      }
    });
    promises.push(req);
  });

  // hide progress message and deselect rows after ALL operations have completed
  jQuery.when.apply(null, promises).always(function() {
    if (!status.progress) {
      jQuery("#progress_message").hide();
      jQuery("#progress_message").html("");
      jQuery('#adminOntologies tbody tr').removeClass('selected');
    }
  });
};

AjaxAction.prototype.ajaxCall = function() {
  var self = this;

  if (self.ontologies.length === 0) {
    alertify.alert("Please select at least one ontology from the table to perform action on.<br/>To select/de-select ontologies, simply click anywhere in the ontology row.");
    return;
  }

  if (self.confirmMsg) {
    alertify.confirm(self.confirmMsg, function(e) {
      if (e) {
        self._ajaxCall();
      }
    });
  } else {
    self._ajaxCall();
  }
};

AjaxAction.prototype.setSelectedOntologies = function() {
  var acronyms = '';
  var ontTable = jQuery('#adminOntologies').DataTable();
  ontTable.rows('.selected').every(function() {
    var trId = this.node().id;
    acronyms += trId.substring("tr_".length) + ",";
  });

  if (acronyms.length) {
    this.ontologies = acronyms.slice(0, -1).split(",");
  } else {
    this.ontologies = [];
  }
};

AjaxAction.prototype.onSuccessAction = function(data, ontology, status) {
  // nothing to do by default
};

AjaxAction.prototype.act = function() {
  alert("AjaxAction.act is not implemented");
};

function ResetMemcacheConnection() {
  AjaxAction.call(this, "POST", "MEMCACHE CONNECTION RESET", "resetcache");
  this.setConfirmMsg('');
}

ResetMemcacheConnection.prototype = Object.create(AjaxAction.prototype);
ResetMemcacheConnection.prototype.constructor = ResetMemcacheConnection;

ResetMemcacheConnection.act = function() {
  new ResetMemcacheConnection().ajaxCall();
};

function FlushMemcache() {
  AjaxAction.call(this, "POST", "FLUSHING OF MEMCACHE", "clearcache");
  this.setConfirmMsg('');
}

FlushMemcache.prototype = Object.create(AjaxAction.prototype);
FlushMemcache.prototype.constructor = FlushMemcache;

FlushMemcache.act = function() {
  new FlushMemcache().ajaxCall();
};

function DeleteSubmission(ontology, submissionId) {
  AjaxAction.call(this, "DELETE", "SUBMISSION DELETION", "ontologies/" + ontology + "/submissions/" + submissionId, {ontologies: ontology});
  this.submissionId = submissionId;
  this.setConfirmMsg("Are you sure you want to delete submission <span style='color:red;font-weight:bold;'>" + submissionId + "</span> for ontology <span style='color:red;font-weight:bold;'>" + ontology + "</span>?<br/><b>This action CAN NOT be undone!!!</b>");
}

DeleteSubmission.prototype = Object.create(AjaxAction.prototype);
DeleteSubmission.prototype.constructor = DeleteSubmission;

DeleteSubmission.prototype.onSuccessAction = function(data, ontology, status) {
  jQuery.facebox({
    ajax: BP_CONFIG.ui_url + "/admin/ontologies/" + ontology + "/submissions?time=" + new Date().getTime()
  });
};

DeleteSubmission.act = function(ontology, submissionId) {
  new DeleteSubmission(ontology, submissionId).ajaxCall();
};

function RefreshReport() {
  AjaxAction.call(this, "POST", "REPORT REGENERATION", "refresh_ontologies_report");
  this.setConfirmMsg("Refreshing this report takes a while...<br/>Are you sure you're ready for some coffee time?");
}

RefreshReport.prototype = Object.create(AjaxAction.prototype);
RefreshReport.prototype.constructor = RefreshReport;

RefreshReport.prototype.onSuccessAction = function(data, ontology, status) {
  var processId = data["process_id"];
  var errors = [];
  var success = [];
  data.success = '';
  status.progress = true;
  var self = this;
  var start = new Date().getTime();
  var timer = setInterval(function() {
    jQuery.ajax({
      url: determineHTTPS(BP_CONFIG.rest_url) + "/admin/ontologies_report/" + processId,
      data: {
        apikey: jQuery(document).data().bp.config.apikey,
        userapikey: jQuery(document).data().bp.config.userapikey,
        format: "jsonp"
      },
      dataType: "jsonp",
      timeout: 30000,
      success: function(data) {
        if (typeof data === 'string') {
          // still processing
          jQuery("#progress_message").append(".");
        } else {
          // done processing, show errors or process data
          if (data.errors && data.errors.length > 0) {
            errors[0] = data.errors[0];
          } else {
            var end = new Date().getTime();
            var tm = end - start;
            success[0] = "Refresh of ontologies report completed in " + millisToMinutesAndSeconds(tm);
            displayOntologies(data);
          }
          clearInterval(timer);
          jQuery("#progress_message").hide();
          self.showStatusMessages(success, errors);
        }
      },
      error: function(request, textStatus, errorThrown) {
        clearInterval(timer);
        errors.push(request.status + ": " + errorThrown);
        jQuery("#progress_message").hide();
        self.showStatusMessages(success, errors);
      }
    });
  }, 5000);
};

RefreshReport.act = function() {
  new RefreshReport().ajaxCall();
};

function DeleteOntologies() {
  AjaxAction.call(this, "DELETE", "ONTOLOGY DELETION", "ontologies");
  this.setSelectedOntologies();
  var ontMsg = this.ontologies.join(", ");
  this.setConfirmMsg("You are about to delete the following ontologies:<br/><span style='color:red;font-weight:bold;'>" + ontMsg + "</span><br/><b>This action CAN NOT be undone!!! Are you sure?</b>");
}

DeleteOntologies.prototype = Object.create(AjaxAction.prototype);
DeleteOntologies.prototype.constructor = DeleteOntologies;
DeleteOntologies.prototype.onSuccessAction = function(data, ontology, status) {
  var ontTable = jQuery('#adminOntologies').DataTable();
  // remove ontology row from the table
  ontTable.row(jQuery("#tr_" + ontology)).remove().draw();
};

DeleteOntologies.act = function() {
  new DeleteOntologies().ajaxCall();
};

function performActionOnOntologies() {
  var action = jQuery('#admin_action').val();

  if (!action) {
    alertify.alert("Please choose an action to perform on the selected ontologies.");
    return;
  }

  switch(action) {
    case "delete":
      DeleteOntologies.act();
      break;
    case "reparse":
      console.log("reparsing");
      break;
  }
}

function populateOntologyRows(data) {
  var ontologies = data.ontologies;
  var allRows = [];
  var hideFields = ["errErrorStatus", "errMissingStatus", "problem", "logFilePath"];

  for (var acronym in ontologies) {
    var errorMessages = [];
    var ontology = ontologies[acronym];
    var ontLink = "<a id='link_submissions_" + acronym + "' href='javascript:;' onclick='showSubmissions(event, \"" + acronym + "\")' style='" + (ontology["problem"] === true ? "color:red" : "") + "'>" + acronym + "</a>";
    var bpLinks = '';

    if (ontology["logFilePath"] != '') {
      bpLinks += "<a href='" + BP_CONFIG.ui_url + "/admin/ontologies/" + acronym + "/log' target='_blank'>Log</a> | ";
    }
    bpLinks += "<a href='" + BP_CONFIG.rest_url + "/ontologies/" + acronym + "' target='_blank'>REST</a> | <a href='" + BP_CONFIG.ui_url + "/ontologies/" + acronym + "' target='_blank'>BioPortal</a>";
    var errStatus = ontology["errErrorStatus"] ? ontology["errErrorStatus"].join(", ") : '';
    var missingStatus = ontology["errMissingStatus"] ? ontology["errMissingStatus"].join(", ") : '';

    for (var k in ontology) {
      if (jQuery.inArray(k, hideFields) === -1) {
        errorMessages.push(ontology[k]);
      }
    }
    row = [ontLink, bpLinks, errStatus, missingStatus, errorMessages.join("<br/>"), ontology["problem"]];
    allRows.push(row);
  }
  return allRows;
}

function setDateGenerated(data) {
  var dateRe = /^\d{2}\/\d{2}\/\d{4}\s\d{2}:\d{2}\w{2}$/i;
  var buttonText = "Generate";

  if (dateRe.test(data.date_generated)) {
    buttonText = "Refresh";
  }
  jQuery(".date_generated").text(data.date_generated).html();
  jQuery(".date_generated_button").text(buttonText).html();
}

function displayOntologies(data) {
  var ontTable = null;

  if (jQuery.fn.dataTable.isDataTable('#adminOntologies')) {
    allRows = populateOntologyRows(data);
    ontTable = jQuery('#adminOntologies').DataTable();
    ontTable.clear();
    ontTable.rows.add(allRows);
    ontTable.draw();
    setDateGenerated(data);
  } else {
    ontTable = jQuery("#adminOntologies").DataTable({
      "ajax": {
        "url": BP_CONFIG.ui_url + "/admin/ontologies_report",
        "contentType": "application/json",
        "dataSrc": function (json) {
          return populateOntologyRows(json);
        }
      },
      "rowCallback": function(row, data, index) {
        var acronym = jQuery('td:first', row).text();
        jQuery(row).attr("id", "tr_" + acronym);

        if (data[data.length - 1] === true) {
          jQuery(row).addClass("problem");
        }
      },
      "initComplete": function(settings, json) {
        setDateGenerated(json);
        // Keep header at top of table even when scrolling








        //new jQuery.fn.dataTable.FixedHeader(ontTable);




      },
      "columnDefs": [
        {
          "targets": 0,
          "searchable": true,
          "title": "Acronym",
          "width": "12%"
        },
        {
          "targets": 1,
          "searchable": false,
          "orderable": false,
          "title": "URL",
          "width": "9%"
        },
        {
          "targets": 2,
          "searchable": true,
          "title": "Error Status",
          "width": "10%"
        },
        {
          "targets": 3,
          "searchable": true,
          "title": "Missing Status",
          "width": "10%"
        },
        {
          "targets": 4,
          "searchable": true,
          "title": "Issues",
          "width": "26%"
        },
        {
          "targets": 5,
          "searchable": true,
          "visible": false
        }
      ],
      "autoWidth": false,
      "lengthChange": false,
      "searching": true,
      "language": {
        "search": "Filter: ",
        "emptyTable": "No ontologies available"
      },
      "info": true,
      "paging": true,
      "pageLength": 100,
      "ordering": true,
      "stripeClasses": ["", "alt"],
      "dom": '<"ontology_nav"><"top"fi>rtip'
    });
  }
  return ontTable;
}

function showSubmissions(ev, acronym) {
  ev.preventDefault();
  jQuery.facebox({ ajax: BP_CONFIG.ui_url + "/admin/ontologies/" + acronym + "/submissions" });
}

jQuery(document).ready(function() {
  // display ontologies table on load
  displayOntologies({});

  // make sure facebox window is empty before populating it
  // otherwise ajax requests stack up and you see more than
  // one ontology's submissions
  jQuery(document).bind('beforeReveal.facebox', function() {
    jQuery("#facebox .content").empty();
  });

  // remove hidden divs for submissions of previously
  // clicked ontologies
  jQuery(document).bind('reveal.facebox', function() {
    jQuery('div[id=facebox]:hidden').remove();
  });

  // convert facebox window into a modal mode
  jQuery(document).bind('loading.facebox', function() {
    jQuery(document).unbind('keydown.facebox');
    jQuery('#facebox_overlay').unbind('click');
  });

  jQuery("div.ontology_nav").html('<span class="toggle-row-display">View Ontologies:&nbsp;&nbsp;&nbsp;&nbsp;<a id="show_all_ontologies_action" href="javascript:;"">All</a> | <a id="show_problem_only_ontologies_action" href="javascript:;">Problem Only</a></span><span style="padding-left:30px;">Apply to Selected Rows:&nbsp;&nbsp;&nbsp;&nbsp;<select id="admin_action" name="admin_action"><option value="">Please Select</option><option value="delete">Delete</option><option value="reparse">Re-parse</option></select>&nbsp;&nbsp;&nbsp;&nbsp;<a class="link_button ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" href="javascript:;" id="admin_action_submit"><span class="ui-button-text">Go</span></a></span>');

  // toggle between all and problem ontologies
  jQuery.fn.dataTable.ext.search.push(
    function(settings, data, dataIndex) {
      var row = settings.aoData[dataIndex].nTr;
      if (!problemOnly || row.classList.contains("problem") || data[data.length - 1] === "true") {
        return true;
      }
      return false;
    }
  );

  // for toggling between all and problem ontologies
  jQuery(".toggle-row-display a").live("click", function() {
    jQuery("#adminOntologies").DataTable().draw();
    return false;
  });

  // allow selecting of rows
  jQuery('#adminOntologies tbody').on('click', 'tr', function() {
    jQuery(this).toggleClass('selected');
  });

  // BUTTON onclick actions ---------------------------------------

  // onclick action for "Go" button for performing an action on a set of ontologies
  jQuery("#admin_action_submit").click(function() {
    performActionOnOntologies();
  });

  // onclick action for "Flush Memcache" button
  jQuery("#flush_memcache_action").click(function() {
    FlushMemcache.act();
  });

  // onclick action for "Reset Memcache Connection" button
  jQuery("#reset_memcache_connection_action").click(function() {
    ResetMemcacheConnection.act();
  });

  // onclick action for "Show All Ontologies" link
  jQuery("#show_all_ontologies_action").click(function() {
    toggleShow(false);
  });

  // onclick action for "Show Problem Only Ontologies" link
  jQuery("#show_problem_only_ontologies_action").click(function() {
    toggleShow(true);
  });

  // onclick action for "Refresh Report" link
  jQuery("#refresh_report_action").click(function() {
    RefreshReport.act();
  });

  // end: BUTTON onclick actions -----------------------------------
});