import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["input", "btnValuefield", "inputValueField", "selectedValues", "inputOntoField", "selectedOntologies"]
    
  connect(){
    this.multipleSelect()
  }

  toggleOtherValue() {
    let attr = this.element.dataset.attribut
    let check = this.element.dataset.check
    if(typeof attr !== "undefined"){
      this.toggle(attr)
    }
    else{
      this.toggle(check)
    }

  }

  multipleSelect(){
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
    
  toggle(attr, event){
    attr = attr.replace('[','');
    attr = attr.replace(']','');
    attr = attr.replace(/"+/g,'');
    attr = attr.replace(/\s+/g, '');
    for (const elem of attr.split(",")) {
      if (document.getElementById('select_' + elem) && document.getElementById('select_' + elem).classList.contains("form-control")){
        if (this.selectedValuesTarget.value == 'other') {
          this.inputValueFieldTarget.value = ""
          this.btnValuefieldTarget.style.display = 'block'
          this.inputValueFieldTarget.style.display = 'block'
        } else {
          this.btnValuefieldTarget.style.display = 'none'
          this.inputValueFieldTarget.style.display = 'none'
        } 
      }
    }
  }


  addValueToSelect()
  {
    let attr = this.element.dataset.attribut
    if(this.inputValueFieldTarget.value) {
      var newOption = this.inputValueFieldTarget.value;
      var selectedOptions = this.selectedValuesTarget.value;
      var option = document.createElement("option");
      option.value = newOption;
      option.text = newOption;
      this.selectedValuesTarget.add(option)
      if (selectedOptions.constructor === Array) {
        selectedOptions.push(newOption);
      } else {
        selectedOptions = newOption;
      }
      this.selectedValuesTarget.value = selectedOptions
      this.inputValueFieldTarget.value = ""
      this.btnValuefieldTarget.style.display = 'none'
      this.inputValueFieldTarget.style.display = 'none'
    }  
  }

  addOntoToSelect()
  {
    let attr = this.element.dataset.attribut
    if(this.inputOntoFieldTarget.value) {
      var newOption = this.inputOntoFieldTarget.value;
      var selectedOptions = [];
      for (var option of this.selectedOntologiesTarget.options) {
        if (option.selected) {
      selectedOptions.push(option.value);
        }
      }
      var option = document.createElement("option");
      option.value = newOption;
      option.text = newOption;
      this.selectedOntologiesTarget.add(option);
      if (selectedOptions === null) {
        selectedOptions = [];
        selectedOptions.push(newOption);
      } else if (selectedOptions.constructor === Array) {
        selectedOptions.push(newOption);
      } else {
        selectedOptions = newOption;
      }
      for (var j = 0; j < this.selectedOntologiesTarget.options.length; j++) {
        this.selectedOntologiesTarget.options[j].selected = selectedOptions.indexOf(this.selectedOntologiesTarget.options[j].value) >= 0;
      }      
      jQuery('[id=select_' + attr + ']').trigger("chosen:updated")
      this.inputOntoFieldTarget.value = "";
    }  
  }

  addInput()
  {
    let attr = this.element.dataset.attribut
    let inputType = this.element.dataset.inputtype
    var container = document.createElement("div");
    container.innerHTML = '<input type="' + inputType + '" name="submission[' + attr + '][]" id="submission_' + attr + '" class="form-control">';
    this.inputTarget.appendChild(container)
  }


}