import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Hello World!")
  }
  showSidebar() {
      console.log("sidebar has been clicked")
      const toggle = document.getElementById("header-toggle")
      const sidebar = document.getElementById("sidebar")
      console.log(toggle)
      console.log(sidebar)
      if(toggle && sidebar){
        sidebar.classList.toggle('show-sidebar')
          toggle.addEventListener('click', ()=>{
              /* Show */
              console.log("sidebar has been clicked")
              sidebar.classList.toggle('show-sidebar')
          })
      }
  }
}
