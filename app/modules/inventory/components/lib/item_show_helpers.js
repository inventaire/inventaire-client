export const getSeriePathname = function (works) {
  if (works?.length !== 1) return
  const work = works[0]
  const seriesUris = work.claims['wdt:P179']
  if (seriesUris?.length === 1) {
    const { uri, pathname } = work
    // Hacky way to get the serie entity pathname without having to request its model
    return pathname.replace(uri, seriesUris[0])
  }
}

export const getAuthorsByProperty = async worksModels => {
  const worksAuthors = await Promise.all(worksModels.map(work => work.getExtendedAuthorsModels()))
  return aggregateAuthorsByProperty(worksAuthors)
}

const aggregateAuthorsByProperty = worksAuthors => {
  const authorsByProperty = {}
  for (const workAuthors of worksAuthors) {
    for (const property in workAuthors) {
      const authors = workAuthors[property] || []
      if (authorsByProperty[property] == null) authorsByProperty[property] = []
      authorsByProperty[property].push(...authors)
    }
  }
  for (const [ property, authors ] of Object.entries(authorsByProperty)) {
    authorsByProperty[property] = authors.map(author => author.toJSON())
  }
  return authorsByProperty
}
