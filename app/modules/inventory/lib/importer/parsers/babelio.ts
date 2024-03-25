import { trim } from '#lib/utils'

export default obj => ({
  rawEntry: obj,
  title: obj.Titre,
  authors: obj.Auteur.split(',').map(trim),
  isbn: obj.ISBN,
  details: obj.Critique,
  publicationDate: formatDate(obj),
})

const formatDate = obj => {
  if (hasValidDate(obj)) {
    // Convert 29/02/2012 to 2012-02-29
    return obj['Date de publication']?.split('/').reverse().join('-')
  }
}

const hasValidDate = obj => {
  // Only exclude what seems to be the default value
  return obj['Date de publication'] !== '0000-00-00'
}
