Q =
  books: [
    'Q571' #book
    'Q2831984' #comic book album
    'Q1004' # bande dessinée / comic book
    'Q14406742' # bande dessinée / comic book series
    'Q8261' #novel / roman
    'Q25379' #theatre play
    'Q7725634' #literary work
    'Q5185279' #poem
    'Q37484' #epic poem
    'Q386724' #work
    'Q49084' #short story / conte
    'Q34620' #Greek tragedy
    'Q8274' #manga
  ]
  edition: [
    'Q3972943' #publishing
    'Q17902573' #edition
  ]
  humans: [
    'Q5'
    'Q10648343' #duo
    'Q14073567' #sibling duo
  ]
  authors: [
    'Q36180' #writer
  ]
  genres: [
    'Q483394' #genre
    'Q223393' #literary genre
  ]

P =
  P50: [
    'P58' #screen writer / scénariste
  ]

aliases = {}

for mainP, aliasedPs of P
  aliasedPs.forEach (aliasedP)->
    aliases[aliasedP] = mainP

Q.softAuthors = Q.authors.concat(Q.humans)

module.exports =
  aliases: aliases
  Q: Q
  P: P
