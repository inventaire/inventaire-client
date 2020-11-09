import forms_ from 'modules/general/lib/forms'

// @ui.message MUST be defined
// poster MUST expect its arguments to be: id, message, collection
// the id being the id of the object the message will be attached to
export default {
  postMessage (posterReqRes, collection, maxLength) {
    const message = this.ui.message.val()
    if (!this.validMessageLength(message, maxLength)) return

    const { id } = this.model

    app.request(posterReqRes, id, message, collection)
    .catch(this.postMessageFail.bind(this, message))

    // empty textarea
    this.lazyRender()
  },

  validMessageLength (message, maxLength = 5000) {
    if (message.length === 0) { return false }
    if (message.length > maxLength) {
      const err = new Error(`can't be longer than ${maxLength} characters`)
      this.postMessageFail(message, err)
      return false
    }
    return true
  },

  postMessageFail (message, err) {
    this.recoverMessage(message)
    err.selector = '.alertBox'
    return forms_.alert(this, err)
  },

  recoverMessage (message) { this.ui.message.val(message) }
}
