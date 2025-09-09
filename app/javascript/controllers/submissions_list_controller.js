// app/javascript/controllers/submissions_list_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["row", "rowCheckbox", "moreLink", "lessLink", "divider", "deleteBtn"]
    static values  = { total: Number, step: Number, min: Number, shown: Number }

    connect() {
        const total = this.hasTotalValue ? this.totalValue : this.rowTargets.length
        const min   = this.hasMinValue ? this.minValue : 5
        const step  = this.hasStepValue ? this.stepValue : 5

        this.totalValue = total
        this.minValue   = min
        this.stepValue  = step
        this.shownValue = Math.min(total, min)
        this.update()
    }

    // UI actions
    showMore(e) { e.preventDefault(); this.shownValue = Math.min(this.totalValue, this.shownValue + this.stepValue); this.update() }
    showLess(e) { e.preventDefault(); this.shownValue = Math.max(this.minValue, this.shownValue - this.stepValue); this.update() }

    // Stage 1: called when any row checkbox changes
    syncSelection() {
        this.updateDeleteButtonState()
    }

    // Internal
    update() {
        // Show first N rows, hide the rest
        this.rowTargets.forEach((tr, idx) => tr.classList.toggle("d-none", idx >= this.shownValue))

        // Uncheck any rows that just became hidden so they don't count toward selection
        this.uncheckHiddenRows()

        // Toggle footer links & divider
        const showMoreVisible = this.shownValue < this.totalValue
        const showLessVisible = this.shownValue > this.minValue

        if (this.hasMoreLinkTarget) this.moreLinkTarget.classList.toggle("d-none", !showMoreVisible)
        if (this.hasLessLinkTarget) this.lessLinkTarget.classList.toggle("d-none", !showLessVisible)
        if (this.hasDividerTarget) this.dividerTarget.classList.toggle("d-none", !(showMoreVisible && showLessVisible))

        // Recompute delete button state after any visibility change
        this.updateDeleteButtonState()
    }

    updateDeleteButtonState() {
        if (!this.hasDeleteBtnTarget) return
        const anyVisibleChecked = this.visibleRowCheckboxes().some(cb => cb.checked)
        this.deleteBtnTarget.disabled = !anyVisibleChecked
    }

    visibleRowCheckboxes() {
        // Row checkboxes whose parent <tr> is not hidden
        const visibleRows = this.rowTargets.filter(tr => !tr.classList.contains("d-none"))
        const boxes = []
        visibleRows.forEach(tr => {
            const cb = tr.querySelector('input[type="checkbox"]')
            if (cb) boxes.push(cb)
        })
        return boxes
    }

    uncheckHiddenRows() {
        // Uncheck any checkboxes that are no longer visible
        this.rowTargets.forEach((tr, idx) => {
            if (idx >= this.shownValue) {
                const cb = tr.querySelector('input[type="checkbox"]')
                if (cb && cb.checked) cb.checked = false
            }
        })
    }
}