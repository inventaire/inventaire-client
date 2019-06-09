module.exports = (part)->
  ordinal = part.get 'claims.wdt:P1545.0'

  unless _.isPositiveIntegerString ordinal
    @worksWithoutOrdinal.add part
    return

  ordinalInt = parseInt ordinal
  if ordinalInt > @maxOrdinal then @maxOrdinal = ordinalInt

  part.set 'ordinal', ordinalInt

  currentOrdinalValue = @worksWithOrdinal[ordinalInt]
  if currentOrdinalValue? then @worksInConflicts.add part
  else @worksWithOrdinal.add part
