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

export const sectionsData = selected => {
  const sections = {
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
    },
  }

  if (sections.entity[selected]) sections.entity[selected].selected = true
  else if (sections.social[selected]) sections.social[selected].selected = true
  else sections.entity.all.selected = true

  if (sections.entity.all.selected) setIncludeFlag(sections.entity)
  else if (sections.social.all.selected) setIncludeFlag(sections.social)

  return sections
}

const setIncludeFlag = categorySections => {
  for (const name in categorySections) {
    if (!neverIncluded.includes(name)) {
      categorySections[name].included = true
    }
  }
}

export const neverIncluded = [ 'all', 'subject' ]
