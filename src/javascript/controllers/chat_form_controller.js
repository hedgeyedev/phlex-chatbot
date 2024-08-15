// app/javascript/controllers/chat_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "messagesContainer", "statusIndicator" ]
  static values = { conversationToken: String, endpoint: String }

  connect() {
    console.log("ChatFormController connected")
    this.setupBotConversation();
    this.resetTextarea()
    this.scrollToBottom()
  }

  setupBotConversation() {
    this.conversation = new EventSource(this.url("join"));
    this.conversation.onerror = event => {
      console.log(`error: ${this.conversation.readyState}`);
      this.messagesContainerTarget.classList.add('pcb__connection-error');
    }
    this.conversation.onopen = event => {
      console.log(`opened: ${this.conversation.readyState}`);
      this.messagesContainerTarget.classList.remove('pcb__connection-error');
    }

    this.conversation.addEventListener("status", event => {
      const parsed = JSON.parse(event.data);
      console.log("Received status:", parsed.message);
      this.statusIndicator.textContent = parsed.message;
    })
    this.conversation.addEventListener("response", event => {
      const parsed = JSON.parse(event.data);
      console.log("Received response:", parsed.message);
      this.showBotResponse(this.messagesContainerTarget.lastElementChild, parsed.message);
    });
    this.conversation.addEventListener("failure", event => {
      const parsed = JSON.parse(event.data);
      console.log("Received failure:", parsed.message);
      this.showBotResponse(this.messagesContainerTarget.lastElementChild, `ERR: ${parsed.message}`);
    });
  }

  submit(event) {
    event.preventDefault()
    const message = this.inputTarget.value.trim()

    if (message) {
      console.log("Sending message:", message)
      this.addMessageToUI(message, true)
      this.resetTextarea();

      const csrf = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      const data = { message }
      const element = this.prepareForResponse();

      fetch(this.url("ask"), {
        method: 'POST',
        body: JSON.stringify(data),
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrf,
        }
      }).then(response => {
        if (response.ok) {
          return null;
        } else {
          throw new Error('Failed to send message')
        }
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
    this.addMessageToUI(userMessage, false);
  }

  scrollToBottom() {
    if (this.hasMessagesContainerTarget) {
      this.messagesContainerTarget.scrollTop = this.messagesContainerTarget.scrollHeight
    }
  }

  url(action) {
    return `${this.endpointValue}/${action}/${this.conversationTokenValue}`
  }
}
