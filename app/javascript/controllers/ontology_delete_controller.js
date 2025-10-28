// app/javascript/controllers/submissions_list_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "button", "input", "confirm"
    ]

    static values = {
        acronym: String
    }

    connect() {
        this.sync()
    }

    sync() {
        const typed = (this.hasInputTarget ? this.inputTarget.value.trim() : "")
        const shouldEnable = typed.toUpperCase() === String(this.acronymValue || "").toUpperCase()
        if (this.hasButtonTarget) {
            this.buttonTarget.disabled = !shouldEnable
        }
    }

    openConfirm() {
        if (this.hasConfirmTarget) {
            this.confirmTarget.classList.remove("d-none")
        }
    }

    confirm() {
        if (this.hasButtonTarget && this.buttonTarget.disabled) return
        if (this.hasConfirmTarget) this.confirmTarget.classList.add("d-none")
        console.log(`deleting ontology ${this.acronymValue}...`)
    }

    cancel() {
        if (this.hasConfirmTarget) {
            this.confirmTarget.classList.add("d-none")
        }
    }




}