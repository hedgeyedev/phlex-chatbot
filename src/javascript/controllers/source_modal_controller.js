import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    document.addEventListener('showSourceModal', this.showModal.bind(this))
  }

  disconnect() {
    document.removeEventListener('showSourceModal', this.showModal.bind(this))
  }

  showModal(event) {
    const { title, description, url } = event.detail

    this.setTextOrHtml(this.modalTarget.querySelector('.pcb__source-modal-title'), title);
    this.setTextOrHtml(this.modalTarget.querySelector('.pcb__source-modal-description'), description);
    this.modalTarget.querySelector('.pcb__source-modal-link').href = url
    this.modalTarget.classList.remove('hide-modal')
  }

  closeModal(event) {
    this.modalTarget.querySelector('.pcb__source-modal-title').innerText = ""
    this.modalTarget.querySelector('.pcb__source-modal-description').innerText = ""
    this.modalTarget.querySelector('.pcb__source-modal-link').href = ""
    this.modalTarget.classList.add('hide-modal')
  }

  setTextOrHtml(element, text) {
    if (text.includes('<')) {
      element.innerHTML = text
    } else {
      element.innerText = text
    }
  }
}
