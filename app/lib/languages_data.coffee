# Completion statistics are updated by scripts/update_languages_stats
# Thus the json syntax

# Letting Norvegian aside for the moment as there are conflicts in the 2 and 4 letters code used to identify the variantes:
# Transifex: uses nb_NO, Wikimedia: nb, no, IETF: nb
# nb:
#   completion: 5
#   defaultRegion: 'nb_NO'

# defaultRegions are needed for 'og:locale' and 'og:locale:alternate'
# that seem to snob 2 letters languages

module.exports = {
  "da": {
    "completion": 25,
    "defaultRegion": "da_DK"
  },
  "de": {
    "completion": 96,
    "defaultRegion": "de_DE"
  },
  "en": {
    "completion": 100,
    "defaultRegion": "en_US"
  },
  "es": {
    "completion": 37,
    "defaultRegion": "es_ES"
  },
  "fr": {
    "completion": 96,
    "defaultRegion": "fr_FR"
  },
  "it": {
    "completion": 14,
    "defaultRegion": "it_IT"
  },
  "ja": {
    "completion": 95,
    "defaultRegion": "ja_JP"
  },
  "no": {
    "completion": 5,
    "defaultRegion": "nb_NO"
  },
  "pl": {
    "completion": 16,
    "defaultRegion": "pl_PL"
  },
  "pt": {
    "completion": 13,
    "defaultRegion": "pt_PT"
  },
  "sv": {
    "completion": 51,
    "defaultRegion": "sv_SE"
  }
}