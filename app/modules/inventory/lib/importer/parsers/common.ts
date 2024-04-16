import leven from 'leven'
// Arbitrary acceptable Levenshtein distance between 2 strings
// to consider it a match. Typically useful to match names despite
// - diacritics: 'René Goscinny' should match 'Rene Goscinny'
// - initials: 'Jean V. Jean' should match 'Jean Jean' within a single work array of authors
// That isn't a very sophisticated matching, but should be a good enough
// first barrier to duplicated authors
const maxLevenshteinDistance = 3

export default function (data) {
  const { authors } = data
  if (authors != null) {
    data.authors = deduplicateAuthors(authors)
  }
  return data
}

const deduplicateAuthors = authors => authors
// Prevent names containing comma to pass as they will later be interpretted
// as several names
.filter(containsNoComma)
.filter(isFirstOccurence(authors))

const containsNoComma = str => (str != null) && !/,/.test(str)

const isFirstOccurence = array => function (str, index) {
  const noramlizedStr = normalize(str)
  for (const previousStr of array.slice(0, index)) {
    if (leven(noramlizedStr, normalize(previousStr)) < maxLevenshteinDistance) return false
  }
  return true
}

const normalize = str => str
.trim()
.normalize()
.toLowerCase()
// Remove standalone initials
.replace(/\s\w{1}\.?\s/, ' ')
.replace(/\W/g, '')
.split('')
// Sort letters to detect inverted names
.sort((a, b) => a.charCodeAt(0) - b.charCodeAt(0))
.join('')
