import { getSubEntities } from '#entities/components/lib/entities'

export async function addWorksEditions (works) {
  await Promise.all(works.map(addWorkEditions))
}

async function addWorkEditions (work) {
  work.editions = await getSubEntities('work', work.uri)
}

export const isOtherEditionWithCover = currentEdition => edition => {
  return (edition.uri !== currentEdition.uri) && edition.image
}
