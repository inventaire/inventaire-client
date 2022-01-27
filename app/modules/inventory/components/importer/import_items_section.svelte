<script>
  import { I18n } from '#user/lib/i18n'
  import _ from 'underscore'
  import Flash from '#lib/components/flash.svelte'
  import Counter from '#components/counter.svelte'
  import app from '#app/app'
  import { createEntitiesByCandidate } from '#inventory/components/importer/create_candidate_entities'
  import { createCandidateItem } from '#inventory/components/importer/create_candidate_item'
  import log_ from '#lib/loggers'

  export let candidates
  export let transaction
  export let listing
  let flash
  let importingCandidates
  let createdItems = []
  const importErr = []
  let processedItems = 0
  let processedEntities = 0

  const importCandidates = async () => {
    flash = null
    if (importingCandidates) return flash = { type: 'warning', message: I18n('already importing books') }
    importingCandidates = true
    if (_.isEmpty(candidates)) return flash = { type: 'warning', message: I18n('no book selected') }

    processedEntities = 0
    await createCandidatesEntities()
    processedItems = 0
    await createItemsSequentially()
    .then(() => {
      if (importErr.length > 0) {
        flash = { type: 'error', message: I18n('not_imported_books', { importErr: importErr.join(', ') }) }
      } else {
        flash = { type: 'success', message: I18n('import completed') }
      }
      importingCandidates = false
    })
  }

  const createCandidatesEntities = async () => {
    const nextCandidate = candidates[processedEntities]
    if (!nextCandidate) return
    processedEntities += 1
    const { customWorkTitle } = nextCandidate
    if (customWorkTitle) {
      const candidateWithEntities = await createEntitiesByCandidate(nextCandidate, importErr)
      candidates = candidates.splice(processedEntities, 1, candidateWithEntities)
    }
    await createCandidatesEntities()
  }

  const createItemsSequentially = async () => {
    const nextCandidate = candidates.pop()
    candidates = candidates
    if (!nextCandidate) return
    processedItems += 1
    await createCandidateItem(nextCandidate, importErr, transaction, listing)
    .then(item => createdItems = [ ...createdItems, item ])
    // do not throw to not crash the whole chain
    .catch(err => {
      importErr.push(nextCandidate.isbnData.isbn)
      log_.error(err, 'createItem err')
    })
    .finally(createItemsSequentially)
  }

  $: candidatesLength = candidates.length
</script>
<div class="importCandidates">
  <h3>4/ {I18n('import this batch')}</h3>
  <Flash bind:state={flash}/>
  <Counter total={candidatesLength} count={processedItems}/>
  {#if flash?.type === 'success'}
    <button
      href="/"
      class="button"
      on:click="{() => app.execute('show:home')}"
      >{I18n('See the new books in my inventory')}</button>
  {:else}
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
