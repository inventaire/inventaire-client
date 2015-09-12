module.exports =
  emailValidation: (email)->
    email = encodeURIComponent email
    "/api/services/public?service=email-validation&email=#{email}"
