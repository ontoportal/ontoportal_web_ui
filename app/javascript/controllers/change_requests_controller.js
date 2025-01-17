import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="change-requests"
export default class extends Controller {
  static targets = [ 'addProposalForm', 'editDefinitionForm' ]

  /*
   * TODO: code for hiding the various change request forms on cancel and submit needs to be refactored
   */

  connect() {
    this.editDefinitionFormTarget.addEventListener('turbo:submit-end', this.hideForm.bind(this));
  }

  clearProposalForm() {
    this.addProposalFormTarget.innerHTML = '';
  }

  clearEditDefinitionForm() {
    this.editDefinitionFormTarget.innerHTML = '';
  }

  hideForm(event) {
    if (event.detail.success) {
      this.editDefinitionFormTarget.innerHTML = '';
    }
  }
}
