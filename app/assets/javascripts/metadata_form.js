$(document).ready(function(){
  updateIdentifierType();
  $("#submission_identifierType").change(function(e){
    updateIdentifierType();
  });
});



/////////////// IDENTIFIER /////////////////////
function updateIdentifierType() {
  let value = $("#submission_identifierType").val();
  disableById('submission_identifier');
  hideElementById('div-cb-require-doi');
  hideElementById('button-load-by-doi');
  $("#doi_request").prop( "checked", false );
  if (typeof value !== 'undefined'){
    switch (value.toLowerCase()) {
      case 'none':      
        showElementById('div-cb-require-doi');
        $("#submission_identifier").val('')
        break;
      case 'doi':      
        enableById('submission_identifier');
        showElementById('button-load-by-doi')
        break;
      case 'other':
        enableById('submission_identifier');
        break;
    }
  }
}

///////////// UTILS ////////////


/**
 * disable the element by Id and all its children
 * @param {*} id 
 */
function disableById(id){
  let elem =  $("#" + id);
  elem.prop("disabled", true); //.addClass('disabled');
  if(elem.children().length) {
    elem.children().prop("disabled", true);
  }
}

function enableById(id){
  let elem =  $("#" + id);
  elem.prop("disabled", false);
  if(elem.children().length) {
    elem.children().prop("disabled", false);
  }
}

function hideElementById(id){
  $("#" + id).hide();
}

function showElementById(id){
  $("#" + id).show();
}


$.escapeSelector = function (txt) {
  return txt.replace(
      /([$%&()*+,./:;<=>?@\[\\\]^\{|}~])/g,
      '\\$1'
  );
};