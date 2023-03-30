import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails";
import { getCookie } from "../mixins/cookie";

// Connects to data-controller="language-change"
export default class extends Controller {

  connect() {
    const locale = getCookie('locale');
    document.querySelector(`#language-select option[value="${locale}"]`)?.selected = true;
  }

  dispatchLangChangeEvent() {
    this.element.dispatchEvent(new CustomEvent('lang_changed', {
      bubbles: true,
      cancelable: true,
      detail: {
        data: {
          language: [this.element.value]
        }
      }
    }));
  }

  setLocale(event) {
    const userPreferedLanguage = event.target.value;
    Turbo.visit(`/locale/${userPreferedLanguage}`);
  }
  
}
