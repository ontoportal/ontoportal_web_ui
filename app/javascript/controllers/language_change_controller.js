import { Controller } from "@hotwired/stimulus"
import { showLoader } from "../mixins/showLoader";

export default class extends Controller {

  static targets = ["sections"]


  onChange(event) {
    showLoader(this.sectionsTarget);
   
    const url = new URL(window.location.href);
    url.searchParams.set('language', event.target.value);

    Turbo.visit(url.toString());
  }

}
