// sidebar_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pcb-sidebar"
export default class extends Controller {
  static targets = ["sidebar", "main", "toggleButton"]
  static classes = ['active'];

  connect() {
    this.checkWindowSize()
    window.addEventListener('resize', this.checkWindowSize.bind(this))
  }

  disconnect() {
    window.removeEventListener('resize', this.checkWindowSize.bind(this))
  }

  checkWindowSize() {
    if (window.innerWidth >= 700) {  // md breakpoint
      this.sidebarTarget.classList.remove('translate-x-full', 'w-full')
      this.toggleButtonTarget.classList.add('hidden')
      this.toggleButtonTarget.classList.remove('pcb__sidebar-activator__deactivate')
    } else {
      this.sidebarTarget.classList.add('translate-x-full')
      this.toggleButtonTarget.classList.remove('hidden')
    }
  }

  toggle() {
    const isVisible = !this.sidebarTarget.classList.contains('translate-x-full')
    this.sidebarTarget.classList.toggle('translate-x-full')

    if (window.innerWidth < 700) {
      // For mobile, toggle between full width and hidden
      this.sidebarTarget.classList.toggle('w-full')
      this.toggleButtonPosition()
    }
  }

  toggleButtonPosition() {
    this.toggleButtonTarget.classList.toggle(this.activeClass)
  }
}
