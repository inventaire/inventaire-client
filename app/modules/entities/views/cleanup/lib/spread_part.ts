import { isPositiveIntegerString } from '#lib/boolean_tests'
export default function (part) {
  const ordinal = part.get('claims.wdt:P1545.0')

  if (!isPositiveIntegerString(ordinal)) {
    this.worksWithoutOrdinal.add(part)
    return
  }

  const ordinalInt = parseInt(ordinal)
  if (ordinalInt > this.maxOrdinal) this.maxOrdinal = ordinalInt

  part.set('ordinal', ordinalInt)

  const currentOrdinalValue = this.worksWithOrdinal[ordinalInt]
  if (currentOrdinalValue != null) {
    return this.worksInConflicts.add(part)
  } else {
    return this.worksWithOrdinal.add(part)
  }
}
