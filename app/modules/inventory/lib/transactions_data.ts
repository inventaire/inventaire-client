// made it a factory has its main use is to be cloned
export const transactionsDataFactory = () => ({
  giving: {
    id: 'giving',
    name: 'giving',
    icon: 'heart',
    label: 'giving',
    labelShort: "I'm giving it",
    labelPersonalized: 'giving_personalized',
    labelPersonalizedStrong: 'giving_personalized_strong',
    creationLabel: 'giving',
    unicodeIcon: '&#xf004;',
  },

  lending: {
    id: 'lending',
    name: 'lending',
    icon: 'refresh',
    label: 'lending',
    labelShort: 'I can lend it',
    labelPersonalized: 'lending_personalized',
    labelPersonalizedStrong: 'lending_personalized_strong',
    creationLabel: 'lending',
    unicodeIcon: '&#xf021;',
  },

  selling: {
    id: 'selling',
    name: 'selling',
    icon: 'money',
    label: 'selling',
    labelShort: "I'm selling it",
    labelPersonalized: 'selling_personalized',
    labelPersonalizedStrong: 'selling_personalized_strong',
    creationLabel: 'selling',
    unicodeIcon: '&#xf0d6;',
  },

  inventorying: {
    id: 'inventorying',
    name: 'inventorying',
    icon: 'cube',
    label: 'in my inventory',
    labelShort: 'in my inventory',
    labelPersonalized: 'inventorying_personalized',
    labelPersonalizedStrong: 'inventorying_personalized_strong',
    creationLabel: 'just_inventorize_it',
    unicodeIcon: '&#xf1b2;',
  },
})

// keep a frozen version of the object at hand for read only
export const transactionsData = Object.freeze(transactionsDataFactory())

type TransactionsData = ReturnType<typeof transactionsDataFactory>
export type TransactionData = TransactionsData[keyof TransactionsData]
