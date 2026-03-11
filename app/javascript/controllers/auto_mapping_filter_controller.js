import { Controller } from "@hotwired/stimulus"
// Connects to data-controller="auto-mapping-filter"

export default class extends Controller {

  toggle(event) {
    const status_hide = event.target.checked 

    const autoSources = ['LOOM']

    this.element.querySelectorAll('tr').forEach((row) => {
      const isAutomatic = autoSources.some((type) =>
        row.classList.contains(type)
      )

      row.style.display = status_hide && isAutomatic ? 'none' : ''
    })
  }
}
