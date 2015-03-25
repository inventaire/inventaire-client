auth = (action)-> "/api/auth?action=#{action}"
authPublic = (action)-> "/api/auth/public?action=#{action}"

module.exports =
  signup:  authPublic 'signup'
  login: authPublic 'login'
  logout: authPublic 'logout'
  usernameAvailability: authPublic 'username-availability'
  emailAvailability: authPublic 'email-availability'
  emailConfirmation: auth 'email-confirmation'
  updatePassword: auth 'update-password'
  resetPassword: authPublic 'reset-password'