{ escapeExpression } = Handlebars

module.exports =
  extract: (lang, title)->
    _.preq.get app.API.data.wikipediaExtract(lang, title)
    .then (data)->
      { extract, url } = data
      # Escaping as extracts are user-generated external content
      # that will be displayed as {{{SafeStrings}}} in views as
      # they are enriched with HTML by sourcedExtract hereafter
      extract = escapeExpression extract
      return sourcedExtract extract, url
    .catch _.ErrorRethrow('wikipediaExtract err')

# Add a link to the full wikipedia article at the end of the extract
sourcedExtract = (extract, url)->
  if extract? and url?
    text = _.i18n 'read_more_on_wikipedia'
    extract += "<br><a href=\"#{url}\" class='source link' target='_blank'>#{text}</a>"

  return extract
