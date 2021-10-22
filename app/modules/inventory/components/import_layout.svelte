<script>
  import { onMount } from 'svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import files_ from '#lib/files'
  import _ from 'underscore'
  import autosize from 'autosize'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import getOriginalLang from '#entities/lib/get_original_lang'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import CandidateRow from '#inventory/components/importer/candidate_row.svelte'
  import dataValidator from '#inventory/lib/data_validator'
  import isbnExtractor from '#inventory/lib/import/extract_isbns'
  import importers from '#inventory/lib/importers'
  import commonParser from '#inventory/lib/parsers/common'
  import screen_ from '#lib/screen'
  import log_ from '#lib/loggers'
  import preq from '#lib/preq'

  onMount(() => autosize(document.querySelector('textarea')))
  let flashIsbnsImporter, flashInvalidIsbns, totalIsbns
  let flashImporters = {}
  let completed = 0
  let isbnsText
  // a preCandidate have an isbnData key when an isbn is found
  let preCandidates = []
  // a candidate have an entities key containing the already known entities in inventaire
  let candidates = []
  let candidatesElement

  const getFile = importer => {
    const { parse, encoding, files } = importer
    // TODO: refactor by turning parsers into async functions
    // which import their dependencies themselves
    return Promise.all([
      files_.readFile('readAsText', files[0], encoding, true),
      import('papaparse'),
      import('isbn3'),
    ])
    // We only need the result from the file
    .then(([ data, { default: Papa }, { default: ISBN } ]) => {
      window.ISBN = ISBN
      window.Papa = Papa
      flashImporters = {}
      dataValidator(importer, data)
      const fileRows = parse(data).map(commonParser)
      const allPreCandidates = fileRows.map(fetchAndAssignIsbnsData)
      removeIsbnKeyIfInvalid(allPreCandidates)
    })
    .then(createCandidates)
    .then(log_.Info('parsed'))
    .catch(log_.ErrorRethrow('parsing error'))
    .catch(message => {
      flashImporters[importer.name] = { type: 'error', message }
    })
  }

  const fetchAndAssignIsbnsData = row => {
    const { isbn } = row
    if (isbn) row.isbnData = isbnExtractor.getIsbnData(isbn)
    return row
  }

  const onIsbnsChange = async () => {
    if (!isbnsText || isbnsText.length === 0) return
    window.ISBN = window.ISBN || (await import('isbn3')).default
    autosize(document.querySelector('textarea'))
    flashIsbnsImporter = false
    // reject invalid isbns as we cannot extract more information from isbnsText
    const isbnsData = isbnExtractor.extractIsbns(isbnsText).filter(isbnData => !isbnData.isInvalid)
    const allPreCandidates = isbnsData.map(isbnData => { return { isbnData } })
    removeIsbnKeyIfInvalid(allPreCandidates)
  }

  const removeIsbnKeyIfInvalid = allPreCandidates => {
    const invalidIsbns = []
    preCandidates = allPreCandidates.map(preCandidate => {
      if (!preCandidate.isbnData || !preCandidate.isbnData.isInvalid) return preCandidate
      invalidIsbns.push(preCandidate.isbnData.rawIsbn)
      delete preCandidate.isbnData
      delete preCandidate.isbn
      return preCandidate
    })
    if (invalidIsbns.length > 0) {
      const message = `${I18n('invalid_isbns_warning')} ${invalidIsbns.join(', ')}`
      // to inventaire-i18n:
      // "invalid_isbns_warning": "those isbns are invalid (mistyping?), books will be created without ISBN"
      flashInvalidIsbns = { type: 'warning', message }
    }
  }

  const emptyIsbns = () => isbnsText = ''

  const createCandidates = async () => {
    totalIsbns = preCandidates.length
    return fetchEntitiesSequentially()
    .then(entities => {
      preCandidates.forEach(buildCandidate(entities))
    })
    .then(() => screen_.scrollToElement(candidatesElement.offsetTop))
  }

  const fetchEntitiesSequentially = () => {
    const preCandidates2 = _.clone(preCandidates)
    const entities = {}
    completed = 0
    const relatives = [ 'wdt:P629', 'wdt:P50' ]
    const fetchEntity = async () => {
      if (preCandidates2.length === 0) return
      const nextPreCandidate = preCandidates2.pop()
      if (nextPreCandidate == null || !nextPreCandidate.isbnData) return
      const uri = `isbn:${nextPreCandidate.isbnData.normalizedIsbn}`
      return preq.get(app.API.entities.getByUris(uri, false, relatives))
      .then(res => {
        _.extend(entities, res.entities)
        completed += 1
      })
      // log errors without throwing to prevent crashing the whole chain
      .catch(log_.Error('fetchEntity err'))
      .then(fetchEntity)
    }

    return Promise.all([
      // using 5 separate channels, fetching entities one by one, instead of
      // by batch, to avoid having one entity blocking a batch progression:
      // the hypothesis is that the request overhead should be smaller than
      // the time a new dataseed-based entity might take to be created
      fetchEntity(), fetchEntity(), fetchEntity(), fetchEntity(), fetchEntity()
    ])
    .then(() => entities)
  }

  const buildCandidate = entities => preCandidate => {
    // minting an index to satisfy svelte #each iteration
    preCandidate.index = Math.random()
    // if preCandidate have no isbn, then it must become a candidate
    // as we cant know if its already a candidate
    const isbn = preCandidate.isbnData?.normalizedIsbn
    if (candidates.find(isAlreadyCandidate(isbn))) return
    if (preCandidate.isbnData) addRelatedEntities(entities, preCandidate)
    addPreCandidateToCandidates(candidates, preCandidate)
  }

  const addRelatedEntities = (entities, candidate) => {
    const editionUri = `isbn:${candidate.isbnData.isbn13}`
    const edition = entities[editionUri]
    if (!edition || edition.type === 'work' || edition.uri.startsWith('wd:')) {
      // Prevent using Wikidata edition entities that arrived here because an edition
      // was linking to them as their work (wdt:P629)
    } else {
      candidate.works = getEditionWorksWithAuthors(edition, entities)
      candidate.edition = edition
    }
  }

  const addPreCandidateToCandidates = (kandidates, candidate) => candidates = [ ...kandidates, candidate ]

  const isAlreadyCandidate = isbn => candidate => candidate.isbnData?.normalizedIsbn === isbn

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
  // isbnsText = ',9782352946847,9782352946847,2277119660,1591841380'
  // Promise.resolve(onIsbnsChange()).then(createCandidates)
</script>
<section>
  <div id="importersWrapper">
    <h3>1/ {I18n('upload your collection from another website')}</h3>
    <ul class="importers">
      {#each importers as importer (importer.name)}
        <li id="{importer.name}-li">
          <div class="importer-data">
            <p class="importerName">
              {#if importer.link}
                <a name={importer.label} href={importer.link}>{importer.label}</a>
              {:else}
                <span title={importer.label}>{importer.label}</span>
              {/if}
              {#if importer.format && importer.format !== 'all'}
                <span class="format">( .{importer.format} )</span>
              {/if}
            </p>
            {#if importer.help}
              <p class="help">{@html I18n(importer.help)}</p>
            {/if}
          </div>
          <input id="{importer.name}" name="{importer.name}" type="file" bind:files={importer.files} accept="{importer.accept}" on:change={getFile(importer)}/>
          <!-- <div class="loading"></div> -->
          <Flash bind:state={flashImporters[importer.name]}/>
        </li>
      {/each}
      <li id="textIsbns-li">
        <div id="isbnsImporter">
          {I18n('text')}
          <div class="textarea-wrapper">
            <textarea id="isbnsTextarea" bind:value={isbnsText} aria-label="{i18n('isbns list')}" placeholder="{i18n('paste any kind of text containing ISBNs here')}" on:change="{onIsbnsChange}"></textarea>
            <a id="emptyIsbns" title="{i18n('clear')}" on:click={emptyIsbns}>{@html icon('trash-o')}</a>
          </div>
          <Flash bind:state={flashIsbnsImporter}/>
          <div class="loading"></div>
        </div>
      </li>
    </ul>
  </div>
  <div class="buttonWrapper">
    <a id="createCandidatesButton" on:click={createCandidates} class="button" tabindex="0">{I18n('find ISBNs')}</a>
  </div>
  {#if completed > 0}
    <p class="loading">
      {completed}/{totalIsbns}
      <Spinner/>
    </p>
  {/if}
  <div id="candidatesElement" bind:this={candidatesElement} hidden="{!candidates.length > 0}">
    <h3>2/ Select the books you want to add</h3>
    <Flash bind:state={flashInvalidIsbns}/>
    <ul>
      {#each candidates as candidate (candidate.index)}
        <CandidateRow bind:candidate={candidate}/>
      {/each}
    </ul>
  </div>
</section>
<style lang="scss">
  @import 'app/modules/general/scss/utils';
  section{
    margin: 1em;
  }
  input{
    padding: auto 0;
  }
  .importerName, #isbnsImporter{
    margin: 0 0.7em;
  }
  .buttonWrapper{
    margin: 1em;
    text-align:center;
  }
</style>
