import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "typingIndicator", "sourceModal", "messagesContainer"]

  connect() {
    console.log("ChatMessagesController connected")
    this.observeMessageAddition()
  }

  observeMessageAddition() {
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.type === 'childList') {
          mutation.addedNodes.forEach((node) => {
            if (node.nodeType === Node.ELEMENT_NODE && node.classList.contains('pcb__message')) {
              this.animateMessage(node)
            }
          })
        }
      })
    })

    observer.observe(this.element, { childList: true, subtree: true })
  }

  animateMessage(message) {
    console.log("Animating new message")
    if (message.classList.contains('pcb__message__user')) {
      message.classList.add('slide-in')
      setTimeout(() => {
        message.classList.remove('slide-in')
      }, 300)
    } else {

      message.classList.add('fade-in')
    }
  }

  messageTargetConnected(message) {
    this.animateMessage(message)
  }



  showTypingIndicator() {
    this.typingIndicatorTarget.classList.remove('hidden')
  }

  hideTypingIndicator() {
    this.typingIndicatorTarget.classList.add('hidden')
  }

  clearChat() {
    console.log("Clearing chat")
    if (this.hasMessagesContainerTarget) {
      this.messagesContainerTarget.innerHTML = ''
    }
  }

  toggleDarkMode() {
    document.body.classList.toggle('dark')
  }

  copyMessage(event) {
    const messageElement = event.target.closest('.pcb__message')
    const messageContent = messageElement.querySelector('.pcb__message__content').textContent

    const copyToClipboard = (text) => {
      if (navigator.clipboard && window.isSecureContext) {
        // Use the Clipboard API when available which it isnt usually in non https environments
        return navigator.clipboard.writeText(text)
      } else {
        // Fallback method using a temporary textarea element
        let textArea = document.createElement("textarea")
        textArea.value = text
        textArea.style.position = "fixed"
        textArea.style.left = "-999999px"
        textArea.style.top = "-999999px"
        document.body.appendChild(textArea)
        textArea.focus()
        textArea.select()
        return new Promise((resolve, reject) => {
          document.execCommand('copy') ? resolve() : reject()
          textArea.remove()
        })
      }
    }

    copyToClipboard(messageContent)
      .then(() => {
        const originalText = event.target.textContent
        event.target.textContent = "Copied!"
        setTimeout(() => {
          event.target.textContent = originalText
        }, 2000)
      })
      .catch(err => {
        console.error('Failed to copy text: ', err)
      })
  }

  regenerateResponse(event) {
    console.log("Regenerate response")
  }


  showSource(event) {
    const title = event.params.sourceTitle,
          description = event.params.sourceDescription,
          url = event.params.sourceUrl;

    const customEvent = new CustomEvent('showSourceModal', {
      bubbles: true,
      detail: { title, description, url }
    })
    console.log("Dispatching showSourceModal event")
    this.element.dispatchEvent(customEvent)
  }
}
