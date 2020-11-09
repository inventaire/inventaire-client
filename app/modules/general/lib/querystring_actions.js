import ValidEmailConfirmation from 'modules/user/views/valid_email_confirmation'

export default function () {
  const validEmail = app.request('querystring:get', 'validEmail')
  if (validEmail != null) {
    // we need to wait for app.user to be ready to get the validEmail value
    return app.request('wait:for', 'user')
    .then(() => app.request('wait:for', 'layout'))
    .then(showValidEmailConfirmation.bind(null, validEmail))
  }
}

const showValidEmailConfirmation = function (validEmail) {
  // user.attribute.validEmail has priority over the validEmail querystring
  // (even if hopefully, there is no reason for those to be different)
  if (app.user.loggedIn) { validEmail = app.user.get('validEmail') }
  return app.layout.modal.show(new ValidEmailConfirmation({ validEmail }))
}
