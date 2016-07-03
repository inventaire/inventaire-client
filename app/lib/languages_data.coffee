# Completion statistics are updated by scripts/update_languages_stats
# Thus the json syntax

# Letting Norvegian aside for the moment as there are conflicts in the 2 and 4 letters code used to identify the variantes:
# Transifex: uses nb_NO, Wikimedia: nb, no, IETF: nb
# nb:
#   completion: 5
#   defaultRegion: 'nb_NO'

module.exports = {
  "da": {
    "completion": 26,
    "defaultRegion": "da_DK"
  },
  "de": {
    "completion": 90,
    "defaultRegion": "de_DE"
  },
  "en": {
    "completion": 100,
    "defaultRegion": "en_US"
  },
  "es": {
    "completion": 11,
    "defaultRegion": "es_ES"
  },
  "fr": {
    "completion": 100,
    "defaultRegion": "fr_FR"
  },
  "it": {
    "completion": 14,
    "defaultRegion": "it_IT"
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
    "completion": 12,
    "defaultRegion": "pt_PT"
  },
  "sv": {
    "completion": 53,
    "defaultRegion": "sv_SE"
  }
}