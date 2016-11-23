{ public:publik } = require('./endpoint')('services')

module.exports =
  emailValidation: (email)->
    _.buildPath publik,
      action: 'email-validation'
      email: _.fixedEncodeURIComponent email
