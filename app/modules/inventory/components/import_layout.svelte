<script>
  import { onMount } from 'svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import files_ from '#lib/files'
  import _ from 'underscore'
  import autosize from 'autosize'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import CandidateRow from '#inventory/components/importer/candidate_row.svelte'
  import dataValidator from '#inventory/lib/data_validator'
  import isbnExtractor from '#inventory/lib/import/extract_isbns'
  import importers from '#inventory/lib/importers'
  import commonParser from '#inventory/lib/parsers/common'
  import screen_ from '#lib/screen'
  import log_ from '#lib/loggers'
  import preq from '#lib/preq'
  import { createCandidate } from '#inventory/lib/import_helpers'

  onMount(() => autosize(document.querySelector('textarea')))
  let flashIsbnsImporter, flashInvalidIsbns
  let checked = true
  let flashImporters = {}
  let isbnsText, preCandidatesCount
  let candidates = []
  let candidatesElement = {}
  let preCandidates = []
  let candidatesLength
  let processedPreCandidates = 0

  const getFile = importer => {
    const { parse, encoding, files } = importer
    // TODO: refactor by turning parsers into async functions
    // which import their dependencies themselves
    flashImporters = {}
    return Promise.all([
      files_.readFile('readAsText', files[0], encoding, true),
      import('papaparse'),
      import('isbn3'),
    ])
    // We only need the result from the file
    .then(([ data, { default: Papa }, { default: ISBN } ]) => {
      window.ISBN = ISBN
      window.Papa = Papa
      dataValidator(importer, data)
      return parse(data).map(commonParser)
    })
    .then(createPreCandidates)
    .then(createAndResolveCandidates)
    .catch(log_.ErrorRethrow('parsing error'))
    .catch(message => flashImporters[importer.name] = { type: 'error', message })
  }

  const onIsbnsChange = async () => {
    if (!isbnsText || isbnsText.length === 0) return
    window.ISBN = window.ISBN || (await import('isbn3')).default
    autosize(document.querySelector('textarea'))
    flashIsbnsImporter = false

    const isbnPattern = /(97(8|9))?[\d-]{9,14}([\dX])/g
    const isbns = isbnsText.match(isbnPattern)
    if (isbns == null) return
    const candidatesData = isbns.map(isbn => { return { isbn } })

    createPreCandidates(candidatesData)
  }

  const createPreCandidates = candidatesData => {
    preCandidates = _.compact(candidatesData.map(createPreCandidate))
  }

  const createPreCandidate = candidateData => {
    const { isbn } = candidateData
    const preCandidate = candidateData
    if (isbn) preCandidate.isbnData = isbnExtractor.getIsbnData(isbn)
    // create preCandidate without isbn and only with new isbn
    if (!isAlreadyCandidate(preCandidate.isbnData.normalizedIsbn)) return preCandidate
  }

  const createAndResolveCandidates = async () => {
    processedPreCandidates = 0
    preCandidatesCount = preCandidates.length
    const remainingPreCandidates = _.clone(preCandidates)

    const createCandidateSequentially = async () => {
      const preCandidate = remainingPreCandidates.pop()
      const nextUri = `isbn:${preCandidate.isbnData.normalizedIsbn}`
      if (!isAlreadyCandidate(preCandidate.isbn)) {
        await preq.get(app.API.entities.getByUris(nextUri, false, relatives))
        .catch(err => { log_.error(err, 'resolver err') })
        .then(createCandidatesFromEntities(preCandidate))
      }
      if (remainingPreCandidates.length === 0) return
      processedPreCandidates += 1
      // increase batch size to reduce queries amount on the long run
      // while serving first results quickly
      createCandidateSequentially()
      // log errors without throwing to prevent crashing the whole chain
      .catch(log_.Error('createCandidateSequentially err'))
    }

    return createCandidateSequentially()
    .then(() => screen_.scrollToElement(candidatesElement.offsetTop))
  }

  // Fetch the works associated to the editions, and those works authors
  // to get access to the authors labels
  const relatives = [ 'wdt:P629', 'wdt:P50' ]

  const createCandidatesFromEntities = preCandidate => res => {
    if (!res) return
    const newCandidate = createCandidate(preCandidate, res.entities)
    candidates = [ ...candidates, newCandidate ]
  }
  const isAlreadyCandidate = normalizedIsbn => _.some(candidates, haveIsbn(normalizedIsbn))

  const haveIsbn = isbn => candidate => candidate.preCandidate.isbnData?.normalizedIsbn === isbn

  const emptyIsbns = () => isbnsText = ''

  const unselectAll = () => {
    // hack to avoid bind:checked of each candidate to this parent component
    // ensure checked is always defined
    checked = true
    checked = false
  }

  $: { candidatesLength = candidates.length }
  // dev stuff, delete before production
  isbnsText = ',9782352946847,9782352946847,2277119660,1591841380,978-2-207-11674-6'
  Promise.resolve(onIsbnsChange()).then(createAndResolveCandidates)
</script>
<section>
  <div id="importersWrapper">
    <h3>1/ {I18n('upload your books')}</h3>
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
          {I18n('import from a list of ISBNs')}
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
    <a id="createCandidatesButton" on:click={createAndResolveCandidates} class="button">{I18n('find ISBNs')}</a>
  </div>
  <div id="candidatesElement" bind:this={candidatesElement} hidden="{!candidates.length > 0}">
    <h3>2/ Select the books you want to add</h3>
    {#if processedPreCandidates > 0 && processedPreCandidates < preCandidatesCount - 1}
      <p class="loading">
        {processedPreCandidates}/{preCandidatesCount}
        <Spinner/>
      </p>
    {/if}
    <Flash bind:state={flashInvalidIsbns}/>
    <ul>
      {#each candidates as candidate}
        <CandidateRow bind:candidate={candidate} checked={checked}/>
      {/each}
    </ul>
    <div id="candidates-nav">
      <button class="grey-button" on:click="{() => checked = true}" name="{I18n('select all')}">
        {I18n('select all')}
      </button>
      <button class="grey-button" on:click={unselectAll} name="{I18n('unselect all')}">
        {I18n('unselect all')}
      </button>
      <button class="grey-button" on:click="{() => candidates = []}" name="{I18n('empty the queue')}">
        <!-- TODO: insert "are you sure" popup -->
        {@html icon('trash')} {I18n('empty the queue')}
      </button>
    </div>
  </div>
</section>
<style lang="scss">
  @import 'app/modules/general/scss/utils';
  section{
    @include display-flex(column);
    margin: 0 auto;
    max-width: 70em;
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
  h3{
    margin-top: 1em;
    text-align: center;
  }
  #candidates-nav{
    @include display-flex(row, center, center, wrap);
    button { margin: 0.5em;}
    margin: 1em;
  }
</style>
