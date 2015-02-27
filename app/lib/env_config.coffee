# only addressing the general case
if location.hostname is 'localhost' then env = 'dev'
else env = 'prod'

module.exports = ->
  if env is 'dev'
    Promise.longStackTraces()