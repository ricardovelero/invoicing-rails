import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect () {
    this.element.setAttribute('novalidate', true)
    this.element.addEventListener('blur', this.onBlur, true)
    this.element.addEventListener('submit', this.onSubmit)
    this.element.addEventListener('ajax:beforeSend', this.onSubmit)
    console.log("Connected")
  }

  disconnect () {
    this.element.removeEventListener('blur', this.onBlur)
    this.element.removeEventListener('submit', this.onSubmit)
    this.element.removeEventListener('ajax:beforeSend', this.onSubmit)
  }

  onBlur = (event) => {
    this.validateField(event.target)
    console.log("Blur")
  }

  onSubmit = (event) => {
    if (!this.validateForm()) {
      event.preventDefault()
      this.firstInvalidField.focus()
    }
  }

  validateForm () {
    let isValid = true
    // Not using `find` because we want to validate all the fields
    this.formFields.forEach((field) => {
      if (this.shouldValidateField(field) && !this.validateField(field)) isValid = false
    })
    return isValid
  }

  validateField (field) {
    if (!this.shouldValidateField(field))
      return true
    const isValid = field.checkValidity()
    field.classList.toggle('invalid', !isValid)
    this.refreshErrorForInvalidField(field, isValid)
    return isValid
  }

  shouldValidateField (field) {
    return !field.disabled && !['file', 'reset', 'submit', 'button'].includes(field.type)
  }

  refreshErrorForInvalidField (field, isValid) {
    this.removeExistingErrorMessage(field)
    if (!isValid)
      this.showErrorForInvalidField(field)
  }

  removeExistingErrorMessage (field) {
    const fieldContainer = field.closest('.field')
    if(!fieldContainer)
      return;
    const existingErrorMessageElement = fieldContainer.querySelector('.error')
    if (existingErrorMessageElement)
      existingErrorMessageElement.parentNode.removeChild(existingErrorMessageElement)
  }

  showErrorForInvalidField (field) {
    field.insertAdjacentHTML('afterend', this.buildFieldErrorHtml(field))
  }

  buildFieldErrorHtml (field) {
    return `<p class="text-red-500 text-sm">${field.validationMessage}</p>`
  }

  get formFields () {
    return Array.from(this.element.elements)
  }

  get firstInvalidField () {
    return this.formFields.find(field => !field.checkValidity())
  }

}