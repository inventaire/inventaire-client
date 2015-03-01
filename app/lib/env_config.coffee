# only addressing the general case
if location.hostname is 'localhost' then window.env = 'dev'
else window.env = 'prod'

module.exports = ->
  if env is 'dev'
    Promise.longStackTraces()
