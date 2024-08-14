// app/javascript/controllers/chat_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "messagesContainer", "statusIndicator" ]
  static values = { endpoint: String }

  connect() {
    console.log("ChatFormController connected")
    this.setupBotSession();
    this.resetTextarea()
    this.scrollToBottom()
  }

  setupBotSession() {
    this.session = new EventSource(this.endpointValue + "/bot/abc");
    this.session.addEventListener("status", event => {
      const parsed = JSON.parse(event.data);
      console.log("Received status:", parsed.message);
      this.statusIndicator.textContent = parsed.message;
    })
    this.session.addEventListener("message", event => {
      const parsed = JSON.parse(event.data);
      console.log("Received message:", parsed.message);
      this.showBotResponse(this.messagesContainerTarget.lastElementChild, parsed.message);
    });
  }

  submit(event) {
    event.preventDefault()
    const message = this.inputTarget.value.trim()
    const botResponse = this.showBotResponse.bind(this)

    if (message) {
      console.log("Sending message:", message)
      this.addMessageToUI(message, true)
      this.resetTextarea();

      const csrf = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      const data = { message }
      const element = this.prepareForResponse();

      fetch(this.endpointValue + "/bot/abc", {
        method: 'POST',
        body: JSON.stringify(data),
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrf,
        }
      }).then(response => {
        if (response.ok) {
          return response.text();
        } else {
          throw new Error('Failed to send message')
        }
      }).then(data => {
        console.log(data);
        //setTimeout(() => { botResponse(element, data.message) }, 5000);
      });
    }
  }

  handleKeydown(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault()
      this.submit(event)
    }
  }

  resetTextarea() {
    this.inputTarget.value = ""
    this.resetTextareaHeight();
  }

  resetTextareaHeight() {
    this.inputTarget.style.height = 'auto'
    this.inputTarget.style.height = this.inputTarget.scrollHeight + 'px'
  }

  addMessageToUI(content, fromUser) {
    if (!this.hasMessagesContainerTarget) {
      console.error("Messages container not found")
      return
    }

    const message = document.getElementById(fromUser ? 'user-message-template' : 'chatbot-message-template')
      .content.children[0].cloneNode(true);
    message.querySelector('.pcb__message__content').innerText = content;

    this.messagesContainerTarget.appendChild(message);

    if (!fromUser) {
      message.classList.add('pcb__message__bot-appear')
    }

    this.scrollToBottom()
  }

  prepareForResponse() {
    if (!this.hasMessagesContainerTarget) {
      console.error("Messages container not found")
      return
    }

    const message = document.getElementById('chatbot-thinking-template').content.children[0].cloneNode(true);
    this.messagesContainerTarget.appendChild(message);
    this.scrollToBottom()

    this.statusIndicator = message.querySelector('.pcb__status-indicator')

    return message;
  }

  showBotResponse(botMessageElement, userMessage) {
    botMessageElement.remove();
    this.addMessageToUI(`I received your message: "${userMessage}"`, false);
  }

  scrollToBottom() {
    if (this.hasMessagesContainerTarget) {
      this.messagesContainerTarget.scrollTop = this.messagesContainerTarget.scrollHeight
    }
  }
}
