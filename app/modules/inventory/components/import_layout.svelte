<script>
  import { onMount } from 'svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import _ from 'underscore'
  import autosize from 'autosize'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import extractIsbns from '#inventory/lib/import/extract_isbns'
  import getOriginalLang from '#entities/lib/get_original_lang'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import CandidateRow from '#inventory/components/importer/candidate_row.svelte'
  import log_ from '#lib/loggers'
  import preq from '#lib/preq'

  onMount(() => autosize(document.querySelector('textarea')))
  let flashIsbns, isbnLoading, totalIsbns, displayEditions
  let completed = 0
  let candidates = []
  let validIsbns = []

  const onIsbnsChange = async value => {
    window.ISBN = window.ISBN || (await import('isbn3')).default
    autosize(document.querySelector('textarea'))
    flashIsbns = false
    const allIsbns = extractIsbns(value)
    const invalidIsbns = allIsbns.filter(_.property('isInvalid'))
    validIsbns = _.difference(allIsbns, invalidIsbns)
    if (invalidIsbns.length > 0) {
      const invalidRawIsbns = invalidIsbns.map(_.property('rawIsbn'))
      const message = `${I18n('invalid_isbns_warning')} ${invalidRawIsbns.join(', ')}`
      // to inventaire-i18n:
      // "invalid_isbns_warning": "those isbns are invalid (mistyping?), they will be ignored"
      flashIsbns = { type: 'warning', message }
    }
  }
  const findIsbns = async () => {
    const isbns = validIsbns.map(_.property('isbn13'))
    totalIsbns = isbns.length
    return fetchEntitiesSequentially(isbns)
    .then(entities => {
      const isbns = _.clone(validIsbns)
      displayEditions = true
      isbns.forEach(assignWorksWithAuthorsToIsbn(entities))
    })
  }

  const fetchEntitiesSequentially = async canonicalIsbns => {
    const isbns = _.clone(canonicalIsbns)
    completed = 0
    const entities = {}
    const relatives = [ 'wdt:P629', 'wdt:P50' ]
    isbnLoading = true
    const fetchEntity = async () => {
      if (isbns.length === 0) return
      const nextIsbn = isbns.pop()
      if (nextIsbn == null) return

      const uri = `isbn:${nextIsbn}`
      return preq.get(app.API.entities.getByUris(uri, false, relatives))
      .then(res => {
        _.extend(entities, res.entities)
        completed += 1
      })
      // Log errors without throwing to prevent crashing the whole chain
      .catch(log_.Error('fetchEntity err'))
      .then(fetchEntity)
    }

    return Promise.all([
      // Using 5 separate channels, fetching entities one by one, instead of
      // by batch, to avoid having one entity blocking a batch progression:
      // the hypothesis is that the request overhead should be smaller than
      // the time a new dataseed-based entity might take to be created
      fetchEntity(), fetchEntity(), fetchEntity(), fetchEntity(), fetchEntity()
    ])
    .then(() => {
      isbnLoading = false
      return entities
    })
  }

  const assignWorksWithAuthorsToIsbn = entities => isbnData => {
    if (candidates.find(isAlreadyIn(isbnData))) return
    const editionUri = `isbn:${isbnData.normalizedIsbn}`
    const edition = entities[editionUri]
    const candidate = { isbnData }
    if (!edition || edition.type === 'work' || edition.uri.startsWith('wd:')) {
      // Prevent using Wikidata edition entities that arrived here because an edition
      // was linking to them as their work (wdt:P629)
    } else {
      candidate.works = getEditionWorksWithAuthors(edition, entities)
      candidate.edition = edition
    }
    addCandidate(candidates, candidate)
  }

  const addCandidate = (kandidates, candidate) => candidates = [ ...kandidates, candidate ]

  const isAlreadyIn = isbnData => candidate => candidate.isbnData.normalizedIsbn === isbnData.normalizedIsbn

  const getEditionWorksWithAuthors = function (edition, entities) {
    const worksUris = edition.claims['wdt:P629']
    const editionLang = getOriginalLang(edition.claims)
    return worksUris.map(getWorkAuthors(entities, editionLang))
  }

  const getWorkAuthors = (entities, editionLang) => workUri => {
    const work = entities[workUri]
    const authorsUris = work.claims['wdt:P50']
    const authors = _.values(_.pick(entities, authorsUris))
    authors.forEach(author => {
      author.bestLangValue = getBestLangValue(editionLang, null, author.labels).value
    })
    work.authors = authors
    work.bestLangValue = getBestLangValue(editionLang, null, work.labels).value
    return work
  }
</script>
<section>
  <h3>1/ {I18n('import from a list of ISBNs')}</h3>
  <div id="isbnsImporter">
    <div class="textarea-wrapper">
      <textarea aria-label="{i18n('isbns list')}" placeholder="{i18n('paste any kind of text containing ISBNs here')}" on:change="{e => onIsbnsChange(e.target.value)}"></textarea>
      <a id="emptyIsbns" title="{i18n('clear')}">{@html icon('trash-o')}</a>
    </div>
    <Flash bind:state={flashIsbns}/>
    <div><span class="warning"></span></div>
    <div class="loading"></div>
    <a id="findIsbns" on:click={findIsbns} class="button" tabindex="0">{I18n('find ISBNs')}</a>
    {#if isbnLoading}
      <p class="loading">
        {#if completed}
          {completed}/{totalIsbns}
        {/if}
        <Spinner/>
      </p>
    {/if}
  </div>
  {#if displayEditions}
    <h3>2/ Select the books you want to add</h3>
    <ul>
      {#each candidates as candidate (candidate.isbnData.normalizedIsbn)}
        <CandidateRow bind:candidate={candidate}/>
      {/each}
    </ul>
  {/if}
</section>
<style lang="scss">
  @import 'app/modules/general/scss/utils';
  section{
    margin: 1em;
  }
</style>
