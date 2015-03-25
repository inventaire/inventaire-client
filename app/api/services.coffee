module.exports =
  emailValidation: (email)->
    "/api/services/public?service=email-validation&email=#{email}"