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

  alterUI(commands) {
    if (!this.hasMessagesContainerTarget) {
      console.error("Messages container not found");
      return;
    }

    commands?.forEach((obj) => {
      const { cmd, element, selector } = obj;
      if (cmd === "append") {
        this.messagesContainerTarget.insertAdjacentHTML("beforeEnd", element);
      } else if (cmd === "delete") {
        this.messagesContainerTarget.querySelector(selector)?.remove();
      }
    });

    this.scrollToBottom()
  }

  dispatchClose(message, event) {
    document.dispatchEvent(
      new CustomEvent("phlex-chatbot:close", {
        bubbles: true,
        detail: { message, event },
      })
    );
  }

  dispatchError(message, event) {
    document.dispatchEvent(
      new CustomEvent("phlex-chatbot:error", {
        bubbles: true,
        detail: { message, event },
      })
    );
  }

  dispatchOpen(message, event) {
    document.dispatchEvent(
      new CustomEvent("phlex-chatbot:open", {
        bubbles: true,
        detail: { message, event },
      })
    );
  }

  dispatchResp(data) {
    const parsed = JSON.parse(data);
    document.dispatchEvent(
      new CustomEvent("phlex-chatbot:resp", {
        bubbles: true,
        detail: { commands: parsed.data },
      })
    );
  }

  registerEventListeners() {
    document.addEventListener("phlex-chatbot:close", (e) => {
      console.debug(e);
      this.messagesContainerTarget.classList.add('pcb__connection-error');
    });

    document.addEventListener("phlex-chatbot:error", (e) => {
      console.debug(e);
      this.messagesContainerTarget.classList.add('pcb__connection-error');
    });

    document.addEventListener("phlex-chatbot:open", (e) => {
      console.debug(e);
      this.messagesContainerTarget.classList.remove('pcb__connection-error');
    });

    document.addEventListener("phlex-chatbot:resp", event => {
      console.debug("Received resp:", event.detail);
      this.alterUI(event.detail.commands);
    });
  }

  setupSseConversation() {
    this.conversation = new EventSource(this.url("join"));
    this.registerEventListeners();

    this.conversation.onerror = event => this.dispatchError("Connection error", event);
    this.conversation.onopen = event => this.dispatchOpen("Connected", event);
    this.conversation.onclose = event => this.dispatchClose("Closed", event);
    this.conversation.addEventListener("resp", event => this.dispatchResp(event.data));
  }

  setupWebSocketConversation() {
    this.conversation = new WebSocket(this.url("join"));
    this.registerEventListeners();

    this.conversation.onerror = event => this.dispatchError("Connection error", event);
    this.conversation.onopen = event => this.dispatchOpen("Connected", event);
    this.conversation.onclose = event => this.dispatchClose("Closed", event);
    this.conversation.onmessage = event => this.dispatchResp(event.data);
  }

  submitWebSocket(event) {
    event.preventDefault();
    const message = this.inputTarget.value.trim();
    this.resetTextarea();

    if (message) {
      console.log("Sending message:", message);
      this.conversation.send(message);
    }
  }

  submitSse(event) {
    event.preventDefault();
    const message = this.inputTarget.value.trim();
    this.resetTextarea();

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

  scrollToBottom() {
    if (this.hasMessagesContainerTarget) {
      this.messagesContainerTarget.scrollTop = this.messagesContainerTarget.scrollHeight
    }
  }

  url(action) {
    return `${this.endpointValue}/${action}/${this.conversationTokenValue}`
  }
}
