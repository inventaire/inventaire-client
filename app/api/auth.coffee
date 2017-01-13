{ public:publik, authentified } = require('./endpoint')('auth')

GetAuthPublic = (action)-> (data)-> _.buildPath publik, _.extend({ action }, data)
postAuthPublic = (action)-> "#{publik}?action=#{action}"
authAuthentified = (action)-> "#{authentified}?action=#{action}"

module.exports =
  usernameAvailability: GetAuthPublic 'username-availability'
  emailAvailability: GetAuthPublic 'email-availability'

  signup: postAuthPublic 'signup'
  login: postAuthPublic 'login'
  logout: postAuthPublic 'logout'
  resetPassword: postAuthPublic 'reset-password'

  emailConfirmation: authAuthentified 'email-confirmation'
  updatePassword: authAuthentified 'update-password'
  # submit: defined directly in index.html form
