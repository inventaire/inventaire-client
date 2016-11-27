# How To
- While in development mode, keys are [automatically](https://github.com/inventaire/inventaire/blob/6fa25ab1c80b3449edd856b7dbe8cd1ce3365dd4/server/controllers/i18n.coffee#L9) added to there respective (`fullkey` or `shortkey`) `en.json` by the server
- Once deployed, Transifex will update its strings lists for all languages from [`en.json`](https://inventaire.io/public/i18n/src/emails/en.transifex.json)
- All contributions should then happen on the [Transifex project](http://transifex.com/inventaire/inventaire/)
- Contributions are then pulled from Transifex to generate the i18n files for each languages

# Details
- keys let empty in `en.json` are those expected to be taken from the client i18n dist files
