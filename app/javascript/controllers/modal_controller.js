// app/javascript/controllers/turbo_modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['name']
  
  connect(){
    this.modal = new bootstrap.Modal(this.element, {
        keyboard: false
    })
    if ($('.fade.show').length == 1){
      this.modal.show()
      this.toggleOtherValue()
      this.multipleSelect()
    }
  } 

  disconnect(){
    this.modal.hide()
  }
    
  toggleOtherValue() {
    let attr = this.element.dataset.attribut;
    attr = attr.replace('[','');
    attr = attr.replace(']','');
    attr = attr.replace(/"+/g,'');
    attr = attr.replace(/\s+/g, '');
    for (const elem of attr.split(",")) {
      if (document.getElementById('select_' + elem) && document.getElementById('select_' + elem).classList.contains("form-control")){
        if ($('#select_' + elem).val() == 'other') {
          $('#add_' + elem).val("");
          $('#btnAdd' + elem).show();
          $('#add_' + elem).show();
        } else {
          $('#btnAdd' + elem).hide();
          $('#add_' + elem).hide();
        } 
      }
    }

  }
    /**
   * To add a new value to selectDropdown when btn clicked
   */
  addValueToSelect()
  {
    let attr = this.element.dataset.attribut
    //let check = this.element.dataset.check
    //if(typeof check !== "undefined"){
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
    //}
    /*else {
      if ($('#select_' + attr).val() !== 'other') {
        $('#btnAdd' + attr).hide();
        $('#add_' + attr).hide();
      }
    }*/
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

  multipleSelect(){
    "use strict";
    jQuery("#naturalLanguageSelect").chosen({
      search_contains: true
    });
    jQuery(".selectOntology").chosen({
      width: '100%',
      search_contains: true
    });
    $('.tooltip_link[title][title!=""]').tooltipster({
      interactive: true,
      position: "right",
      contentAsHTML: true,
      animation: 'fade',
      delay: 200,
      theme: 'tooltipster-shadow',
      trigger: 'hover'
    });
  }

  addContact(event) {
    event.preventDefault();
  
    var contacts = document.querySelectorAll("table.contact");
    var newContact = contacts[0].cloneNode(true);
    //newContact.classList.add("offset-sm-2");
    console.log(newContact)
    //var removeButton = newContact.querySelector("button");
    //removeButton.classList.replace("btn-success", "btn-danger");
    //removeButton.classList.replace("add-contact", "remove-contact");
    //removeButton.classList.add("ml-1")
    //removeButton.querySelector("i").classList.replace("fa-plus", "fa-minus");
    //newContact.appendChild(removeButton);
    
    var index = contacts.length;
    var inputs = newContact.getElementsByTagName("input");
    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
  
      var id = input.getAttribute("id").replace(/0/g, index);
      input.setAttribute("id", id);
  
      var name = input.getAttribute("name").replace(/0/g, index);
      input.setAttribute("name", name);
      
      input.setAttribute("value", "");
  
      input.removeAttribute("required");
    }
  
    contacts[index - 1].insertAdjacentElement('afterend', newContact);
  }
}
