import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pcb-source-modal"
export default class extends Controller {
  static targets = [
    "modal",
    "title",
    "content",
    "link"
  ]

  show(event) {
    event.preventDefault()
    const { title, content, link } = event.params
    this.setTextOrHtml(this.titleTarget, title)
    this.setTextOrHtml(this.contentTarget, content)
    this.modalTarget.classList.remove('hide-modal')

    if (this.hasLinkTarget) {
      this.linkTarget.href = link;
    }
  }

  hide(event) {
    event.preventDefault()
    this.titleTarget.innerText = ""
    this.contentTarget.innerText = ""
    this.modalTarget.classList.add('hide-modal')

    if (this.hasLinkTarget) {
      this.linkTarget.href = "";
    }
  }

  setTextOrHtml(element, text) {
    if (text.includes('<')) {
      element.innerHTML = text
    } else {
      element.innerText = text
    }
  }
}
