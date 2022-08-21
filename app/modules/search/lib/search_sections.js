export const typesBySection = {
  entity: {
    all: [ 'works', 'humans', 'series', 'publishers', 'collections' ],
    work: 'works',
    author: 'humans',
    serie: 'series',
    collection: 'collections',
    publisher: 'publishers',
    subject: 'subjects',
  },
  social: {
    all: [ 'users', 'groups' ],
    user: 'users',
    group: 'groups'
  }
}

export const categoryBySection = {}

for (const category of Object.keys(typesBySection)) {
  for (const section of Object.keys(typesBySection[category])) {
    if (section !== 'all') categoryBySection[section] = category
  }
}

export const entitySectionsWithAlternatives = [ 'all', 'work', 'author', 'serie', 'collection', 'publisher' ]

export const sections = {
  entity: {
    all: { label: 'all' },
    work: { label: 'work' },
    author: { label: 'author' },
    serie: { label: 'series_singular' },
    publisher: { label: 'publisher' },
    collection: { label: 'collection' },
    subject: { label: 'subject' }
  },
  social: {
    all: { label: 'all' },
    user: { label: 'user' },
    group: { label: 'group' },
  }
}

const sectionsNames = {
  entity: Object.keys(sections.entity),
  social: Object.keys(sections.social),
}

export const getPrevSection = ({ selectedCategory, selectedSection }) => {
  const categorySections = sectionsNames[selectedCategory]
  const index = categorySections.indexOf(selectedSection)
  if (categorySections[index - 1]) {
    selectedSection = categorySections[index - 1]
  } else {
    selectedCategory = getOtherCategory(selectedCategory)
    selectedSection = sectionsNames[selectedCategory].slice(-1)[0]
  }
  return { selectedCategory, selectedSection }
}
export const getNextSection = ({ selectedCategory, selectedSection }) => {
  const categorySections = sectionsNames[selectedCategory]
  const index = categorySections.indexOf(selectedSection)
  if (categorySections[index + 1]) {
    selectedSection = categorySections[index + 1]
  } else {
    selectedCategory = getOtherCategory(selectedCategory)
    selectedSection = sectionsNames[selectedCategory][0]
  }
  return { selectedCategory, selectedSection }
}

const getOtherCategory = category => category === 'entity' ? 'social' : 'entity'
