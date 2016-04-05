module.exports = (lang)->
  validLang = pickMomentLang lang
  # _.log "moment lang: #{lang} -> #{validLang}"
  if validLang?
    _.preq.getScript app.API.scripts.moment(lang)
    .then -> moment.locale lang
    # .then _.Log('moment locale set')
    .catch _.Error('fetchMomentLocale err')

pickMomentLang = (lang)->
  lang = lang.toLowerCase()
  if lang in momentLang then return lang
  else null



momentLang = ['af','ar','ar-ma','ar-sa','az','be','bg','bn','bo','br','bs',
'ca','cs','cv','cy','da','de-at','de','el','en-au','en-ca','en-gb','eo','es',
'et','eu','fa','fi','fo','fr-ca','fr','gl','he','hi','hr','hu','hy-am','id',
'is','it','ja','ka','km','ko','lb','lt','lv','mk','ml','mr','ms-my','my','nb',
'ne','nl','nn','pl','pt-br','pt','ro','ru','sk','sl','sq','sr-cyrl','sr','sv',
'ta','th','tl-ph','tr','tzm','tzm-latn','uk','uz','vi','zh-cn','zh-tw']
