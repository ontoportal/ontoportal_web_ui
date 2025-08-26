// app/javascript/controllers/user_ontology_log_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets= ["content"]
    static values= { url: String }

    connect() {
        // Initial load
        this.load()
    }

    refresh(event) {
        if (event) event.preventDefault()
        this.load()
    }

    load() {
        const url = this.urlValue
        if (!url) return

        // CSRF for Rails (not strictly required for GET, but harmless)
        const tokenEl = document.querySelector('meta[name="csrf-token"]')
        const headers = tokenEl ? { 'X-CSRF-Token': tokenEl.content } : {}

        this.contentTarget.textContent = "Loading…"

        fetch(url, { headers })
            .then(r => r.text())
            .then(text => {
                this.contentTarget.textContent = text
            })
            .catch(err => {
                this.contentTarget.textContent = 'Failed to load log: ${err}'
            })
    }
}