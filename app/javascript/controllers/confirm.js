// Custom TailwindCSS modals for confirm dialogs
function insertConfirmModal(message, element) {
  let content = `
    <div id="confirm-modal" class="z-50 animated fadeIn fixed top-0 left-0 w-full h-full table" style="background-color: rgba(0, 0, 0, 0.8);">
      <div class="table-cell align-middle">

        <div class="bg-white mx-auto rounded shadow p-8 max-w-sm">
          <h4>${message}</h4>

          <div class="flex justify-end items-center flex-wrap mt-6">
            <button data-behavior="cancel" class="btn btn-light-gray mr-2">Cancel</button>
            <button data-behavior="commit" class="btn btn-danger focus:outline-none">Confirm</button>
          </div>
        </div>
      </div>
    </div>
  `

  element.insertAdjacentHTML('afterend', content)
  return element.nextElementSibling
}

Turbo.setConfirmMethod((message, element) => {
  let dialog = insertConfirmModal(message, element)

  return new Promise((resolve, reject) => {
    dialog.querySelector("[data-behavior='cancel']").addEventListener("click", (event) => {
      dialog.remove()
      resolve(false)
    }, { once: true })
    dialog.querySelector("[data-behavior='commit']").addEventListener("click", (event) => {
      dialog.remove()
      resolve(true)
    }, { once: true })
  })
})

const Rails = require("@rails/ujs")

// Cache a copy of the old Rails.confirm since we'll override it when the modal opens
const old_confirm = Rails.confirm;

// Elements we want to listen to for data-confirm
const elements = ['a[data-confirm]', 'button[data-confirm]', 'input[type=submit][data-confirm]']

const createConfirmModal = (element) => {
  let modal = insertConfirmModal(element.dataset.confirm, element)

  element.dataset.confirmModal = `#${id}`

  modal.addEventListener("keyup", (event) => {
    if(event.key === "Escape") {
      event.preventDefault()
      element.removeAttribute("data-confirm-modal")
      modal.remove()
    }
  })

  modal.querySelector("[data-behavior='cancel']").addEventListener("click", (event) => {
    event.preventDefault()
    element.removeAttribute("data-confirm-modal")
    modal.remove()
  }, { once: true })
  modal.querySelector("[data-behavior='commit']").addEventListener("click", (event) => {
    event.preventDefault()

    // Allow the confirm to go through
    Rails.confirm = () => { return true }

    // Click the link again
    element.click()

    // Remove the confirm attribute and modal
    element.removeAttribute("data-confirm-modal")
    Rails.confirm = old_confirm

    modal.remove()
  }, { once: true })

  modal.querySelector("[data-behavior='commit']").focus()
  return modal
}

// Checks if confirm modal is open
const confirmModalOpen = (element) => {
  return !!element.dataset.confirmModal;
}

const handleConfirm = (event) => {
  // If there is a modal open, let the second confirm click through
  if (confirmModalOpen(event.target)) {
    return true

  // First click, we need to spawn the modal
  } else {
    createConfirmModal(event.target)
    return false
  }
}

// When a Rails confirm event fires, we'll handle it
Rails.delegate(document, elements.join(', '), 'confirm', handleConfirm)
