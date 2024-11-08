import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="change-requests"
export default class extends Controller {
  static targets = [ 'addProposalForm' ]

  clearProposalForm() {
    this.addProposalFormTarget.innerHTML = '';
  }
}
