import { Controller } from "@hotwired/stimulus"

// FIXME(Chris): Do we want to refactor out a controller specifically for the input?
// Connects to data-controller="pcb-chat-form"
export default class extends Controller {
  static targets = ["input"];

  connect() {
    // clear form
    this.element.reset()
  }

  resize() {
    this.inputTarget.style.height = 'auto'
    this.inputTarget.style.height = this.inputTarget.scrollHeight + 'px'
  }

  submit() {
    this.element.requestSubmit();
  }
}
