import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pcb-chat-form"
export default class extends Controller {

  connect() {
    // console.log("pcb ChatFormController connected")
    // clear form

    this.element.reset()
  }

  // Add behavior to submitting the form:
  // 1. Change the text
  // 2. Prevent the default form submission
  // 3. disable the form
  // 4. Send the form
  // submitForm(event) {
  //   this.submitButtonTarget.textContent = "Sending..."
  //   event.preventDefault()
  //   this.formTarget.disabled = true
  //   this.formTarget.requestSubmit()
  // }
}
