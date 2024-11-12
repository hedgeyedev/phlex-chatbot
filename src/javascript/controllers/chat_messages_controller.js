import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pcb-chat-messages"
export default class extends Controller {
  static targets = ["message"]

  connect() {
    // console.log("pcb ChatMessagesController connected")
    this.element.lastElementChild.scrollIntoView({ block: "end", inline: "nearest" })
  }

  messageTargetConnected(element) {
    // console.log("Message connected")
    element.scrollIntoView({ block: "end", inline: "nearest", behavior: "smooth" }) //

    if (element.dataset.pcbChatMessageType === 'user') {
      this.animateNewMessage(element)
    }
  }

  animateNewMessage(element) {
    element.classList.add('slide-in')
    setTimeout(() => {
      element.classList.remove('slide-in')
    }, 300)
  }
}
