<script>
  import { onMount } from 'svelte'
  import { I18n, i18n } from 'modules/user/lib/i18n'
  import { icon } from 'lib/utils'
  import _ from 'underscore'
  import autosize from 'autosize'
  import Flash from 'lib/components/flash.svelte'
  import Spinner from 'modules/general/components/spinner.svelte'
  import extractIsbns from 'modules/inventory/lib/import/extract_isbns'
  import log_ from 'lib/loggers'
  import preq from 'lib/preq'

  onMount(() => autosize(document.querySelector('textarea')))

  let hideFlashIsbns, showFlashIsbns, isbnSpinner
  let completed = 0
  let validIsbns = [], allIsbns = [], invalidIsbns = []
  const relatives = [ 'wdt:P629', 'wdt:P50' ]

  const onIsbnsChange = async value => {
    window.ISBN = window.ISBN || (await import('isbn3')).default
    autosize(document.querySelector('textarea'))
    hideFlashIsbns()
    allIsbns = extractIsbns(value)
    invalidIsbns = allIsbns.filter(_.property('isInvalid'))
    validIsbns = _.difference(allIsbns, invalidIsbns)
    if (invalidIsbns.length > 0) {
      const invalidRawIsbns = invalidIsbns.map(_.property('rawIsbn'))
      const message = `${I18n('invalid_isbns_warning')} ${invalidRawIsbns.join(', ')}`
      // to inventaire-i18n:
      // "invalid_isbns_warning": "those isbns are invalid (mistyping?), they will be ignored if continuing:"
      showFlashIsbns({
        priority: 'warning',
        message
      })
    }
  }
  const findIsbns = async () => {
    return fetchEntitiesSequentially(validIsbns)
    .then(foo => { console.log('..--####### LOG ######--..', foo); return foo })
  }

  const fetchEntitiesSequentially = async isbnsData => {
    completed = 0
    const uris = []
    const isbnsIndex = {}
    const commonRes = {
      entities: {},
      redirects: {},
      notFound: [],
      invalidIsbn: []
    }
    isbnsData.forEach((isbnData, index) => {
      isbnData.index = index
      isbnsIndex[isbnData.isbn13] = isbnData
      // Invalid ISBNs won't have an isbn13 set, but there is always a normalized ISBN
      // so we re-index it
      isbnsIndex[isbnData.normalizedIsbn] = isbnData
      if (isbnData.isInvalid) {
        return commonRes.invalidIsbn.push(isbnData)
      } else {
        isbnData.uri = `isbn:${isbnData.isbn13}`
        return uris.push(isbnData.uri)
      }
    })

    if (uris.length === 0) return Promise.resolve({ results: commonRes, isbnsIndex })

    const updateProgression = function () {
      completed += 1
    }

    const fetchOneByOne = async () => {
      const nextUri = uris.pop()
      if (nextUri == null) return

      return preq.get(app.API.entities.getByUris(nextUri, false, relatives))
      .then(res => {
        _.extend(commonRes.entities, res.entities)
        _.extend(commonRes.redirects, res.redirects)
        res.notFound?.forEach(pushNotFound(isbnsIndex, commonRes))
      })
      .then(updateProgression)
      // Log errors without throwing to prevent crashing the whole chain
      .catch(log_.Error('fetchOneByOne err'))
      .then(fetchOneByOne)
    }

    updateProgression()

    return Promise.all([
      // Using 5 separate channels, fetching entities one by one, instead of
      // by batch, to avoid having one entity blocking a batch progression:
      // the hypothesis is that the request overhead should be smaller than
      // the time a new dataseed-based entity might take to be created
      fetchOneByOne(), fetchOneByOne(), fetchOneByOne(), fetchOneByOne(), fetchOneByOne()
    ])
    .then(() => ({
      results: commonRes,
      isbnsIndex
    }))
  }

  const pushNotFound = (isbnsIndex, commonRes) => function (uri) {
    const isbn13 = uri.split(':')[1]
    const isbnData = isbnsIndex[isbn13]
    return commonRes.notFound.push(isbnData)
  }
</script>

<section>
  <h3>1/ {I18n('import from a list of ISBNs')}</h3>
  <div id="isbnsImporter">
    <div class="textarea-wrapper">
      <textarea aria-label="{i18n('isbns list')}" placeholder="{i18n('paste any kind of text containing ISBNs here')}" on:keyup="{e => onIsbnsChange(e.target.value)}"></textarea>
      <a id="emptyIsbns" title="{i18n('clear')}">{@html icon('trash-o')}</a>
    </div>
    <Flash bind:show={showFlashIsbns} bind:hide={hideFlashIsbns}/>
    {#if isbnSpinner}
      <p class="loading">Loading... <Spinner/></p>
    {/if}
    <div><span class="warning"></span></div>
    <div class="loading"></div>
    <a id="findIsbns" on:click="{findIsbns}" class="success-button">{I18n('find ISBNs')}</a>
  </div>
  {completed}
</section>
<style lang="scss">
  @import 'app/modules/general/scss/utils';
</style>
