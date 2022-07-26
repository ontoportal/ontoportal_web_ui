import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    addValueToSelect()
    {
      let attr = this.element.dataset.attribut
        if(jQuery('#add_' + attr).val()) {
          var newOption = jQuery('#add_' + attr).val();
          var selectedOptions = jQuery('#select_' + attr).val();
          jQuery('#select_' + attr).append(jQuery('<option>', {
            value: newOption,
            text: newOption
          }));
          if (selectedOptions.constructor === Array) {
            selectedOptions.push(newOption);
          } else {
            selectedOptions = newOption;
          }
          jQuery('#select_' + attr).val(selectedOptions)
          jQuery('#add_' + attr).val("");
          jQuery('#btnAdd' + attr).hide();
          jQuery('#add_' + attr).hide();
        }  
    }

    addOntoToSelect()
    {
      let attr = this.element.dataset.attribut
      if(jQuery('#add_' + attr).val()) {
        var newOption = jQuery('#add_' + attr).val();
        var selectedOptions = jQuery('#select_' + attr).val();
        jQuery('#select_' + attr).append(jQuery('<option>', {
          value: newOption,
          text: newOption
        }));
        if (selectedOptions === null) {
          selectedOptions = [];
          selectedOptions.push(newOption);
        } else if (selectedOptions.constructor === Array) {
          selectedOptions.push(newOption);
        } else {
          selectedOptions = newOption;
        }
        jQuery('#select_' + attr).val(selectedOptions)
        jQuery('#select_' + attr).trigger("chosen:updated");
        jQuery('#add_' + attr).val("");
      }
    }

    addInput()
    {
      let attr = this.element.dataset.attribut
      let inputType = this.element.dataset.inputType
      var container = document.createElement("div");
      container.innerHTML = '<input type="' + inputType + '" name="submission[' + attr + '][]" id="submission_' + attr + '" class="form-control">';
      document.getElementById(attr + 'Div').appendChild(container);
    }
  
  
  
}