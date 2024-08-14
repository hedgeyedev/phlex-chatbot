import { Application } from "@hotwired/stimulus"

// Import all controllers
import ChatFormController from "./controllers/chat_form_controller"
import ChatMessagesController from "./controllers/chat_messages_controller"
import SidebarController from "./controllers/sidebar_controller"
import SourceModalController from "./controllers/source_modal_controller"

const application = Application.start()

// Manually register each controller
application.register("chat-form", ChatFormController)
application.register("chat-messages", ChatMessagesController)
application.register("sidebar", SidebarController)
application.register("source-modal", SourceModalController)

// You can add any other initializations or imports here