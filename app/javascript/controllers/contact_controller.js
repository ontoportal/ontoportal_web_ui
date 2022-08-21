import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  
    static targets = ["contactName", "contactEmail", "currentContact", "contacts"]
    addContact(event) {
        event.preventDefault();
        var contacts = document.querySelectorAll("div.contact");
        var newContact = this.currentContactTarget.cloneNode(true);
        var removeButton = newContact.querySelector("button").cloneNode(true);
        removeButton.classList.replace("btn-success", "btn-danger");
        removeButton.classList.replace("add-contact", "remove-contact");
        removeButton.dataset.action = "click->contact#removeContact"
        removeButton.classList.add("ml-1")
        removeButton.querySelector("i").classList.replace("fa-plus", "fa-minus");
        newContact.appendChild(removeButton);
        var inputs = newContact.getElementsByTagName('input')
        for (let index = 0; index < inputs.length; index++) {
          inputs[index].value = ''      
        }
        this.contactsTarget.appendChild(newContact);
      }

    removeContact(event) {
        event.preventDefault();
        var target = event.target;
        var contact;
        if (target.matches("button.remove-contact")) {
          contact = target.parentNode;
        } else if (target.matches("i.fa-minus")) {
          contact = target.parentNode.parentNode;
        }
        this.contactsTarget.removeChild(contact);
    }
    
}