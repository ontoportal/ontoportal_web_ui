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
    
 

  changeDate(){
    console.log("mouad is")
    jQuery(".datepicker").each(function() {
      $(this).datepicker({
        dateFormat: "M d, yy",
      });
    });
    console.log("hi")
  }
}
