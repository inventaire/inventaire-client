<script>
  import { I18n } from '#user/lib/i18n'
  import _ from 'underscore'
  import Flash from '#lib/components/flash.svelte'
  import Counter from '#components/counter.svelte'
  import { createItem } from '#inventory/components/create_item'
  import ImportResults from '#inventory/components/importer/import_results.svelte'
  import screen_ from '#lib/screen'
  import { resolveAndCreateCandidateEntities } from '#inventory/lib/import_helpers'

  export let candidates
  export let transaction
  export let listing
  export let shelvesIds
  let flash
  let importingCandidates
  let processedCandidates = []
  let processedItemsCount = 0
  let processedEntitiesCount = 0
  let importResultsElement = {}

  const importCandidates = async () => {
    flash = null
    if (importingCandidates) {
      return flash = { type: 'warning', message: I18n('already importing books') }
    }
    importingCandidates = true

    if (_.isEmpty(candidates.filter(_.property('checked')))) {
      importingCandidates = false
      return flash = { type: 'warning', message: I18n('no book selected') }
    }

    processedEntitiesCount = 0
    await createEntitiesSequentially()
    processedItemsCount = 0
    await createItemsSequentially()
    importingCandidates = false
    removeCreatedCandidates()
    if (importResultsElement) screen_.scrollToElement(importResultsElement.offsetTop)
  }

  const removeCreatedCandidates = async () => {
    const createdIndices = processedCandidates.map(createdCandidate => {
      if (createdCandidate.item) return createdCandidate.index
    })
    candidates = candidates.filter(candidate => !createdIndices.includes(candidate.index))
  }

  const createEntitiesSequentially = async () => {
    const candidatePosition = processedEntitiesCount
    const nextCandidate = candidates[candidatePosition]
    if (!nextCandidate) return
    processedEntitiesCount += 1
    try {
      const candidateWithEntities = await resolveAndCreateCandidateEntities(nextCandidate)
      candidates[candidatePosition] = candidateWithEntities
    } catch (err) {
      // Do not throw to not crash the whole chain
      const { responseJSON } = err
      nextCandidate.error = responseJSON
      candidates[candidatePosition] = nextCandidate
    }
    await createEntitiesSequentially()
  }

  const createItemsSequentially = async () => {
    const candidatePosition = processedItemsCount
    const nextCandidate = candidates[candidatePosition]
    if (!nextCandidate) return
    processedItemsCount += 1
    if (nextCandidate.checked && !nextCandidate.error) {
      const { edition, details, notes } = nextCandidate
      try {
        const item = await createItem(edition, details, notes, transaction, listing, shelvesIds)
        nextCandidate.item = item
      } catch (err) {
        // Do not throw to not crash the whole chain
        const { responseJSON } = err
        nextCandidate.error = responseJSON
      }
    }
    processedCandidates = [ ...processedCandidates, nextCandidate ]
    await createItemsSequentially()
  }
</script>
<div class="import-candidates">
  {#if candidates.length > 0}
    <h3>4/ {I18n('import the selection')}</h3>
    <Flash bind:state={flash}/>
    <Counter count={processedEntitiesCount} total={candidates.length} message='creating bibliographical data'/>
    <Counter count={processedItemsCount} total={candidates.length} message='creating your books'/>
    <button
      class="button success"
      disabled={importingCandidates}
      on:click={importCandidates}
      >
      {I18n('create selected books')}
    </button>
  {/if}
  {#if processedCandidates.length > 0}
    <ImportResults bind:this={importResultsElement} {transaction} {listing} bind:processedCandidates/>
  {/if}
</div>
<style lang="scss">
  @import '#general/scss/utils';
  h3{
    margin-top: 1em;
    text-align: center;
    font-weight: bold;
  }
  .import-candidates {
    @include display-flex(column, center, null, wrap);
    button { margin: 1em 0; }
  }
  button:disabled{
    opacity: 0.6;
  }
</style>
