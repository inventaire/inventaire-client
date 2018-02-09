module.exports =
  setAttributes: (attrs)->
    attrs.extract or= attrs.description
    if attrs.extract?
      attrs.extractOverflow = attrs.extract.length > 600

    return
