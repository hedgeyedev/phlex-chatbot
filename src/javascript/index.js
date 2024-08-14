import { Application } from "@hotwired/stimulus"

// Import all controllers
import ChatFormController from "./controllers/chat_form_controller"
import ChatMessagesController from "./controllers/chat_messages_controller"
import SidebarController from "./controllers/sidebar_controller"
import SourceModalController from "./controllers/source_modal_controller"

const application = Application.start()

// Manually register each controller
application.register("pcb-chat-form", ChatFormController)
application.register("pcb-chat-messages", ChatMessagesController)
application.register("pcb-sidebar", SidebarController)
application.register("pcb-source-modal", SourceModalController)

// You can add any other initializations or imports here
