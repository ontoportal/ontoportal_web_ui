import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    
    connect(){
      this.hideLoader()
    }
    
    disconnect(){
      this.showLoader()
    }

    showLoader(){
      let table = document.querySelector(".table-container")
      if (table){
        console.log("hide table", table)
        table.style.display = "block"
      }
      document.getElementById("metadataTableloader").style.display = "block"
    }

    hideLoader(){
      document.getElementById("metadataTableloader").style.display = "none"
    }

}