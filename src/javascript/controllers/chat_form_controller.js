import { Controller } from "@hotwired/stimulus"

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
