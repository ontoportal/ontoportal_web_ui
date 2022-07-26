import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  
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
  
  toggle(attr){
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


}