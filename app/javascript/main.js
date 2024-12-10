// sidebar //
const showSidebar = (toggleId, sidebarId) =>{
    console.log("sidebar has been clicked")
    const toggle = document.getElementById(toggleId),
    const sidebar = document.getElementById(sidebarId)
         
    if(toggle && sidebar && header && main){
        toggle.addEventListener('click', ()=>{
            /* Show */
            console.log("sidebar has been clicked")
            sidebar.classList.toggle('show-sidebar')
        })
    }
}
    
 showSidebar('header-toggle','sidebar')
