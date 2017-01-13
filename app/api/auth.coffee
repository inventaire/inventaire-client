{ public:publik, authentified } = require('./endpoint')('auth')

GetAuthPublic = (action, attribute)-> (value)->
  data = { action }
  data[attribute] = encodeURIComponent value
  return _.buildPath publik, data

postAuthPublic = (action)-> "#{publik}?action=#{action}"
authAuthentified = (action)-> "#{authentified}?action=#{action}"

module.exports =
  usernameAvailability: GetAuthPublic 'username-availability', 'username'
  emailAvailability: GetAuthPublic 'email-availability', 'email'

  signup: postAuthPublic 'signup'
  login: postAuthPublic 'login'
  logout: postAuthPublic 'logout'
  resetPassword: postAuthPublic 'reset-password'

  emailConfirmation: authAuthentified 'email-confirmation'
  updatePassword: authAuthentified 'update-password'
  # submit: defined directly in index.html form
