// app/javascript/controllers/chat_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "messagesContainer", "statusIndicator" ]
  static values = {
    conversationToken: String,
    driver: { type: String, default: "websocket" },
    endpoint: String,
  }

  connect() {
    console.log("ChatFormController connected")
    if (this.driverValue === "sse") {
      this.setup = this.setupSseConversation;
      this.submit = this.submitSse;
    } else if (this.driverValue === "websocket") {
      this.setup = this.setupWebSocketConversation;
      this.submit = this.submitWebSocket;
    }
    this.setup();
    this.resetTextarea()
    this.scrollToBottom()
  }

  registerEventListeners() {
    document.addEventListener("phlex-chatbot:error", () => {
      console.log(`error: ${this.conversation.readyState}`);
      this.messagesContainerTarget.classList.add('pcb__connection-error');
    });

    document.addEventListener("phlex-chatbot:open", () => {
      console.log(`opened: ${this.conversation.readyState}`);
      this.messagesContainerTarget.classList.remove('pcb__connection-error');
    });

    document.addEventListener("phlex-chatbot:ack", event => {
      console.log("Received ack:", event.detail.message);
      this.addMessageToUI(event.detail.message, true)
      this.resetTextarea();
      this.prepareForResponse();
      this.statusIndicator.textContent = event.detail.message;
    });

    document.addEventListener("phlex-chatbot:status", event => {
      console.log("Received status:", event.detail.message);
      this.statusIndicator.textContent = event.detail.message;
    });

    document.addEventListener("phlex-chatbot:response", event => {
      console.log("Received response:", event.detail.message);
      this.showBotResponse(this.messagesContainerTarget.lastElementChild, event.detail.message);
    });

    document.addEventListener("phlex-chatbot:failure", event => {
      console.log("Received failure:", event.detail.message);
      this.showBotResponse(this.messagesContainerTarget.lastElementChild, `ERR: ${event.detail.message}`);
    });
  }

  dispatchAck(data) {
    const parsed = JSON.parse(data);
    document.dispatchEvent(
      new CustomEvent("phlex-chatbot:ack", {
        bubbles: true,
        detail: { message: parsed.data.message },
      })
    );
  }

  dispatchError(message, readyState) {
    document.dispatchEvent(
      new CustomEvent("phlex-chatbot:error", {
        bubbles: true,
        detail: { message, readyState },
      })
    );
  }

  dispatchOpen(message, readyState) {
    document.dispatchEvent(
      new CustomEvent("phlex-chatbot:open", {
        bubbles: true,
        detail: { message, readyState },
      })
    );
  }

  dispatchStatus(data) {
    const parsed = JSON.parse(data);
    document.dispatchEvent(
      new CustomEvent("phlex-chatbot:status", {
        bubbles: true,
        detail: { message: parsed.data.message },
      })
    );
  }

  dispatchResponse(data) {
    const parsed = JSON.parse(data);
    document.dispatchEvent(
      new CustomEvent("phlex-chatbot:response", {
        bubbles: true,
        detail: { message: parsed.data.message },
      })
    );
  }

  dispatchFailure(data) {
    const parsed = JSON.parse(data);
    document.dispatchEvent(
      new CustomEvent("phlex-chatbot:failure", {
        bubbles: true,
        detail: { message: parsed.data.message },
      })
    );
  }

  setupSseConversation() {
    this.conversation = new EventSource(this.url("join"));
    this.registerEventListeners();

    this.conversation.onerror = _event => this.dispatchError("Connection error", this.conversation.readyState);
    this.conversation.onopen = _event => this.dispatchOpen("Connected", this.conversation.readyState);

    this.conversation.addEventListener("ack", event => this.dispatchAck(event.data));
    this.conversation.addEventListener("status", event => this.dispatchStatus(event.data));
    this.conversation.addEventListener("response", event => this.dispatchResponse(event.data));
    this.conversation.addEventListener("failure", event => this.dispatchFailure(event.data));
  }

  setupWebSocketConversation() {
    this.conversation = new WebSocket(this.url("join"));
    this.registerEventListeners();

    this.conversation.onerror = _event => this.dispatchError("Connection error", this.conversation.readyState);
    this.conversation.onopen = _event => this.dispatchOpen("Connected", this.conversation.readyState);
    this.conversation.onmessage = event => {
      const parsed = JSON.parse(event.data);
      if (parsed.event === "ack") {
        this.dispatchAck(event.data);
      } else if (parsed.event === "status") {
        this.dispatchStatus(event.data);
      } else if (parsed.event === "response") {
        this.dispatchResponse(event.data);
      } else if (parsed.event === "failure") {
        this.dispatchFailure(event.data);
      }
    }
  }

  submitWebSocket(event) {
    event.preventDefault();
    const message = this.inputTarget.value.trim();

    if (message) {
      console.log("Sending message:", message);
      this.conversation.send(message);
    }
  }

  submitSse(event) {
    event.preventDefault()
    const message = this.inputTarget.value.trim()

    if (message) {
      console.log("Sending message:", message)

      const csrf = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      const data = { message }

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
