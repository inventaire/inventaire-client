module.exports =
  welcome:
    path: 'welcome'
    tests:
      expectedContent: (html)->
        re = new RegExp 'id="lastPublicBooks"'
        unless re.test html
          throw new Error 'missing element'

      built: (html)->
        re = new RegExp '<!-- PIWIK -->'
        if re.test html
          throw new Error "html isn't in built state"

      minified: (html)->
        re = new RegExp '<meta charset="utf-8"><meta'
        unless re.test html
          throw new Error "html isn't minified"
