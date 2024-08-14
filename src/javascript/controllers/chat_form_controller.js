// app/javascript/controllers/chat_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "messagesContainer", "statusIndicator" ]

  connect() {
    console.log("ChatFormController connected")
    this.resetTextareaHeight()
    this.scrollToBottom()
  }

  submit(event) {
    event.preventDefault()
    const message = this.inputTarget.value.trim()
    if (message) {
      console.log("Sending message:", message)

      this.addMessageToUI(message, true)
      this.simulateBotResponse(message)

      this.inputTarget.value = ""
      this.resetTextareaHeight()
    }
  }

  handleKeydown(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault()
      this.submit(event)
    }
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

  simulateBotResponse(userMessage) {
    if (!this.hasMessagesContainerTarget) {
      console.error("Messages container not found")
      return
    }

    const stages = ['Retrieving relevant documents', 'Reranking results', 'Thinking'];
    let currentStage = 0;

    const message = document.getElementById('chatbot-thinking-template').content.children[0].cloneNode(true);
    this.messagesContainerTarget.appendChild(message);
    this.scrollToBottom()

    const statusIndicator = message.querySelector('.pcb__status-indicator')

    const updateStatus = () => {
      if (currentStage < stages.length) {
        statusIndicator.textContent = stages[currentStage];
        currentStage++;
        setTimeout(updateStatus, 1000); // Move to next stage after 1 second
      } else {
        this.showBotResponse(message, userMessage);
      }
    };

    setTimeout(updateStatus, 1000); // Start updating after 1 second
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
