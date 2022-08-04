// app/javascript/controllers/turbo_modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  
  connect(){
    this.modal = new bootstrap.Modal(this.element, {
        keyboard: false
    })
    if ($('.fade.show').length == 1){
      this.modal.show()
    }
  } 

  disconnect(){
    this.modal.hide()
  }

  showNewContent(event){
    let frame = document.querySelector('turbo-frame#metadata_by_ontology')
    frame.src = "ontologies_metadata_curator/show_metadata_by_ontology/" + event.target.value
    frame.reload()
  }

    
 }
