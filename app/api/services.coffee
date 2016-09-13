{ public:publik } = require('./endpoint')('services')

module.exports =
  emailValidation: (email)->
    _.buildPath publik,
      service: 'email-validation'
      email: _.fixedEncodeURIComponent email
