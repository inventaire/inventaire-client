try
  muted = require('../local_config').muted
catch err
  muted = []

all = [
  'i18n'
  'qLabel'
  'setCookie'
  'app'
  'route'
  'entity'
  'entities'
  'item'
  'inv'
  'query'
  'relations'
]

module.exports = _.difference all, muted