<script>
  import { I18n } from '#user/lib/i18n'
  import _ from 'underscore'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import log_ from '#lib/loggers'
  import app from '#app/app'

  export let candidates
  export let transaction
  export let listing
  let flashImportCandidates
  let candidatesLength
  let importingCandidates
  let processedCandidates = 0

  const importCandidates = async () => {
    flashImportCandidates = null
    if (importingCandidates) return flashImportCandidates = { type: 'warning', message: I18n('already importing books') }
    importingCandidates = true
    if (_.isEmpty(candidates)) return flashImportCandidates = { type: 'warning', message: I18n('no book selected') }
    processedCandidates = 0

    const remainingCandidates = _.clone(candidates)
    const failedImports = []

    const createItem = async () => {
      const nextCandidate = remainingCandidates.splice(0, 1)[0]
      if (nextCandidate.checked) {
        const { uri: editionUri } = nextCandidate.edition
        if (editionUri) {
          await app.request('item:create', {
            transaction,
            listing,
            details: nextCandidate.details,
            entity: editionUri
          })
          .catch(err => {
            failedImports.push(nextCandidate.preCandidate.isbn)
            log_.error(err, 'createItem err')
          })
        }
      }
      processedCandidates += 1
      if (remainingCandidates.length === 0) return
      await createItem()
    }

    return createItem()
    .then(() => {
      if (failedImports.length > 0) {
        flashImportCandidates = { type: 'error', message: I18n('not_imported_books', { failedImports: failedImports.join(', ') }) }
      } else {
        flashImportCandidates = { type: 'success', message: I18n('import completed') }
      }
      importingCandidates = false
    })
  }

  $: candidatesLength = candidates.length
</script>
<div class="importCandidates">
  <h3>4/ {I18n('import this batch')}</h3>
  <Flash bind:state={flashImportCandidates}/>
  {#if flashImportCandidates?.type === 'success'}
    <button
      href="/"
      class="button"
      on:click="{() => app.execute('show:home')}"
      >{I18n('See the new books in my inventory')}</button>
  {:else}
    {#if processedCandidates > 0 && processedCandidates < candidatesLength}
      <p class="loading">
        {processedCandidates}/{candidatesLength}
        <Spinner/>
      </p>
    {/if}
    <button
      class="importCandidatesButton button success"
      class:disabled={importingCandidates}
      on:click={importCandidates}
      >
      {I18n('import the selection')}
    </button>
  {/if}
</div>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  h3{
    margin-top: 1em;
    text-align: center;
  }
  .importCandidates {
    @include display-flex(column, center, center, wrap);
    button { margin: 1em 0; }
    text-align:center;
  }
</style>
