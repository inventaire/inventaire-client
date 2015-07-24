module.exports = (Items)->
  Items.transactions =
    giving:
      id: 'giving'
      icon: 'heart'
      label: 'giving'
      labelShort: "I'm giving it"
      labelPersonalized: 'giving_personalized'
      unicodeIcon:'&#xf004;'
    lending:
      id: 'lending'
      icon: 'refresh'
      label: 'lending'
      labelShort: "I can lend it"
      labelPersonalized: 'lending_personalized'
      unicodeIcon:'&#xf021;'
    selling:
      id: 'selling'
      icon: 'money'
      label: 'selling'
      labelShort: "I'm selling it"
      labelPersonalized: 'selling_personalized'
      unicodeIcon:'&#xf0d6;'
    inventorying:
      id: 'inventorying'
      icon: 'cube'
      label: 'in my inventory'
      labelShort: 'in my inventory'
      labelPersonalized: 'inventorying_personalized'
      unicodeIcon:'&#xf1b2;'
