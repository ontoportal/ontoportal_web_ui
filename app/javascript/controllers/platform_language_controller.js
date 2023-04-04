import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="platform-language"
// this controller is used to change the language of the whole platform
export default class extends Controller {

  connect() {
    const locale = getCookie('locale');
    document.querySelector(`#language-select option[value="${locale}"]`)?.selected = true;
  }

  handleLangChanged(event) {
    console.log("handleLangChanged", event);
    debugger
    const userPreferedLanguage = event.target.value;
    Turbo.visit(`/locale/${userPreferedLanguage}`);
  }
}
