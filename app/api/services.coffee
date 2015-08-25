module.exports =
  emailValidation: (email)->
    "/api/services/public?service=email-validation&email=#{email}"
  parseEmails: '/api/services?service=parse-emails'