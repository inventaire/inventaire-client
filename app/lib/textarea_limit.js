export default {
  updateLimit (textareaEl, limitEl, limit) {
    const currentLength = this.ui[textareaEl].val().length
    if ((currentLength / limit) > 0.9) {
      const remaingCharacters = limit - currentLength
      const counter = `<span class='counter'>${remaingCharacters}</span>`
      const text = `${_.i18n('remaing characters:')} ${counter}`
      const className = remaingCharacters < 0 ? 'exceeded' : 'good'
      return this.ui[limitEl].html(`<p class='${className}'>${text}</p>`)
    } else {
      return this.ui[limitEl].html('<p class="good"></p>')
    }
  }
}
