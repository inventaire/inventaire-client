module.exports = (part)->
  ordinal = part.get 'claims.wdt:P1545.0'

  unless _.isPositiveIntegerString ordinal
    @withoutOrdinal.add part
    return

  ordinalInt = parseInt ordinal
  if ordinalInt > @maxOrdinal then @maxOrdinal = ordinalInt

  part.set 'ordinal', ordinalInt

  currentOrdinalValue = @withOrdinal[ordinalInt]
  if currentOrdinalValue? then @conflicts.add part
  else @withOrdinal.add part
