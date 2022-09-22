import {Controller} from "@hotwired/stimulus"
import {UseModal} from "../mixins/useModal";

// Connects to data-controller="show-modal"
export default class extends Controller {
    static values = {
        targetModal: {type: String, default: '#application_modal'},
        title: String,
    }


    connect() {
        this.modal = new UseModal()
        this.boundHide = this.hide.bind(this)
        this.modal.onClose(this.element,  this.boundHide)
    }

    disconnect() {
        this.modal.onCloseRemoveEvent(this.element, this.boundHide)
    }

    show() {
        this.setTitle()
        let target = this.targetModalElement
        if (target) {
            this.modal.showModal(target)
        }
    }

    hide() {
        let target = this.targetModalElement
        if (target) {
            this.modal.hideModal(target)
        }

    }

    get targetModalElement() {
        return document.querySelector(this.targetModalValue)
    }

    get modalTitle() {
        return document.querySelector(`${this.targetModalValue} .modal-title`)
    }

    setTitle() {
        let titleElem = this.modalTitle
        if(titleElem){
            titleElem.innerHTML = this.titleValue
        }
    }
}
