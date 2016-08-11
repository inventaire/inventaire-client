Q =
  books: [
    'wd:Q571' #book
    'wd:Q2831984' #comic book album
    'wd:Q1004' #bande dessinée / comic book
    'wd:Q1760610' #comic book
    'wd:Q14406742' #bande dessinée / comic book series
    'wd:Q8261' #novel / roman
    'wd:Q25379' #theatre play
    'wd:Q7725634' #literary work
    'wd:Q17518870' #group of literary works
    'wd:Q5185279' #poem
    'wd:Q12308638' #poetry anthology
    'wd:Q37484' #epic poem
    'wd:Q386724' #work
    'wd:Q49084' #short story / conte
    'wd:Q34620' #Greek tragedy
    'wd:Q8274' #manga
    'wd:Q128093' #ebook
    'wd:Q128093' #ebook
  ]
  edition: [
    'wd:Q3331189' #edition
    'wd:Q3972943' #publishing
  ]
  articles: [
    'wd:Q191067' #article
    'wd:Q13442814' #scientific article
  ]
  humans: [
    'wd:Q5'
    'wd:Q10648343' #duo
    'wd:Q14073567' #sibling duo
  ]
  authors: [
    'wd:Q36180' #writer
  ]
  genres: [
    'wd:Q483394' #genre
    'wd:Q223393' #literary genre
  ]

P =
  'wdt:P50': [
    'wdt:P58' #screen writer / scénariste
  ]

aliases = {}

for mainP, aliasedPs of P
  for aliasedP in aliasedPs
    aliases[aliasedP] = mainP

Q.softAuthors = Q.authors.concat(Q.humans)

module.exports =
  aliases: aliases
  Q: Q
  P: P
