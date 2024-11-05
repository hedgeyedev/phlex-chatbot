// app/javascript/controllers/chat_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "messagesContainer", "statusIndicator" ]
  static values = {
    conversationToken: String,
    driver: { type: String, default: "websocket" },
    endpoint: String,
    pingMs: { type: Number, default: 17000 },
  }

  connect() {
    console.debug("stimulus connect")
    this.reconnectAttempts = 0;

    console.debug("ChatFormController connected")
    this.registerEventListeners();

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

  disconnect() {
    console.debug("stimulus disconnect");
    this.unregisterEventListeners();

    if (this.driverValue === "sse") {
      this.teardownSseConversation();
    } else {
      this.teardownWebSocketConversation();
    }
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
        this.scrollToBottom();
      } else if (cmd === "delete") {
        this.messagesContainerTarget.querySelector(selector)?.remove();
        this.scrollToBottom();
      }
    });
  }

  disableInput() {
    this.disabled = true;
    this.inputTarget.parentElement.querySelector('button').disabled = true;
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

  enableInput() {
    this.disabled = false;
    this.inputTarget.parentElement.querySelector('button').disabled = false;
  }

  handleKeyboardSubmit(event) {
    if (!this.disabled) {
      this.submit(event);
    }
  }

  reconnect() {
    if (this.reconnecting) {
      return;
    }

    this.reconnecting = true;
    this.reconnectAttempts += 1;
    const timeout = Math.min(5, ((this.reconnectAttempts - 1) ** 1.3));
    console.debug(`Reconnecting in ${timeout}s (attempt ${this.reconnectAttempts})`);
    setTimeout(() => {
      this.setup();
      this.reconnecting = false;
    }, timeout * 1000);
  }

  registerEventListeners() {
    this.disconnectCallback = (e) => {
      console.debug(e);
      this.reconnect();
      setTimeout(() => {
        if (this.conversation.readyState !== EventSource.OPEN || this.conversation.readyState !== WebSocket.OPEN) {
          this.disableInput();
          this.messagesContainerTarget.classList.add('pcb__connection-error');
        }
      }, 100);
    };

    this.openCallback = (e) => {
      console.debug(e);
      this.reconnectAttempts = 0;
      this.enableInput();
      this.messagesContainerTarget.classList.remove('pcb__connection-error');
    }

    this.responseCallback = (e) => {
      console.debug("Received resp:", event.detail);
      this.alterUI(event.detail.commands);
    }

    document.addEventListener("phlex-chatbot:close", this.disconnectCallback);
    document.addEventListener("phlex-chatbot:error", this.disconnectCallback);
    document.addEventListener("phlex-chatbot:open", this.openCallback);
    document.addEventListener("phlex-chatbot:resp", this.responseCallback);
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

  setupSseConversation() {
    if (this.conversation?.readyState === EventSource.OPEN) {
      console.debug("sse already connected");
      return;
    }

    this.conversation = new EventSource(this.url("join"));
    this.conversation.onerror = event => this.dispatchError("Connection error", event);
    this.conversation.onopen = event => this.dispatchOpen("Connected", event);
    this.conversation.onclose = event => this.dispatchClose("Closed", event);
    this.conversation.addEventListener("resp", event => this.dispatchResp(event.data));
  }

  setupWebSocketConversation() {
    if (this.conversation?.readyState === WebSocket.OPEN) {
      console.debug("websocket already connected");
      return;
    }

    this.conversation = new WebSocket(this.url("join"));
    this.conversation.onerror = event => this.dispatchError("Connection error", event);
    this.conversation.onopen = event => this.dispatchOpen("Connected", event);
    this.conversation.onclose = event => this.dispatchClose("Closed", event);
    this.conversation.onmessage = event => {
      if (event.data === "pong") { return; }
      this.dispatchResp(event.data);
    }

    if (!this.pingTask) {
      this.pingTask = setInterval(() => {
        if (this.conversation.readyState !== WebSocket.OPEN) {
          return;
        }

        console.debug("sending ping");
        this.conversation.send("ping");
      }, this.pingMsValue);
    }
  }

  submitWebSocket(event) {
    event.preventDefault();
    const message = this.inputTarget.value.trim();
    this.resetTextarea();

    if (message) {
      console.debug("Sending message:", message);
      this.conversation.send(message);
    }
  }

  submitSse(event) {
    event.preventDefault();
    const message = this.inputTarget.value.trim();
    this.resetTextarea();

    if (message) {
      console.debug("Sending message:", message)

      fetch(this.url("ask"), {
        method: 'POST',
        body: JSON.stringify({ message }),
        headers: { "Content-Type": "application/json" },
      }).then(response => {
        if (response.ok) {
          return null;
        } else {
          throw new Error('Failed to send message')
        }
      });
    }
  }

  teardownSseConversation() {
    if (this.conversation) {
      console.debug("tearing down SSE conversation");
      this.conversation.close();
    }
  }

  teardownWebSocketConversation() {
    if (this.conversation) {
      console.debug("tearing down websocket conversation");
      this.conversation.onclose = () => { console.debug("websocket closed") };
      this.conversation.close();
      if (this.pingTask) {
        console.debug("shutting down websocket keep-alive pinger");
        clearInterval(this.pingTask);
      }
    }
  }

  unregisterEventListeners() {
    document.removeEventListener("phlex-chatbot:close", this.disconnectCallback);
    document.removeEventListener("phlex-chatbot:error", this.disconnectCallback);
    document.removeEventListener("phlex-chatbot:open", this.openCallback);
    document.removeEventListener("phlex-chatbot:resp", this.responseCallback);
    console.debug("unregistered event listeners");
  }

  url(action) {
    const encodedToken = encodeURIComponent(this.conversationTokenValue);
    return `${this.endpointValue}/${action}/${encodedToken}`
  }
}
