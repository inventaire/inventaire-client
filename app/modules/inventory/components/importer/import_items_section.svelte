<script>
  import { I18n } from '#user/lib/i18n'
  import _ from 'underscore'
  import Flash from '#lib/components/flash.svelte'
  import Counter from '#components/counter.svelte'
  import { createItemFromCandidate } from '#inventory/components/importer/lib/create_item'
  import ImportResults from '#inventory/components/importer/import_results.svelte'
  import screen_ from '#lib/screen'
  import { resolveAndCreateCandidateEntities } from '#inventory/lib/importer/import_helpers'
  import { isAlreadyResolved, removeCreatedCandidates } from '#inventory/components/importer/lib/import_items_helpers'

  export let candidates
  export let transaction
  export let listing
  export let shelvesIds
  let flash
  let importingCandidates
  let processedCandidates = []
  let processedItemsCount = 0
  let processedEntitiesCount = 0
  let importResultsElement

  $: selectedCandidates = candidates.filter(_.property('checked'))

  const importCandidates = async () => {
    flash = null
    try {
      importingCandidates = true
      processedEntitiesCount = 0
      await createEntitiesSequentially()
      processedItemsCount = 0
      await createItemsSequentially()
      importingCandidates = false
      candidates = removeCreatedCandidates({ candidates, processedCandidates })
      if (importResultsElement) screen_.scrollToElement(importResultsElement)
    } catch (err) {
      importingCandidates = false
      flash = err
    }
  }

  const createEntitiesSequentially = async () => {
    const candidatePosition = processedEntitiesCount
    const nextCandidate = candidates[candidatePosition]
    if (!nextCandidate) return
    processedEntitiesCount += 1
    try {
      if (nextCandidate.checked && !isAlreadyResolved(nextCandidate)) {
        let candidateWithEntities
        candidateWithEntities = await resolveAndCreateCandidateEntities(nextCandidate)
        candidates[candidatePosition] = candidateWithEntities
      }
    } catch (err) {
      // Do not throw to not crash the whole chain
      const { responseJSON } = err
      nextCandidate.error = responseJSON
      candidates[candidatePosition] = nextCandidate
      flash = err
    }
    await createEntitiesSequentially()
  }

  const createItemsSequentially = async () => {
    const candidatePosition = processedItemsCount
    const nextCandidate = candidates[candidatePosition]
    if (!nextCandidate) return
    processedItemsCount += 1
    if (nextCandidate.checked && !nextCandidate.error) {
      await createItemFromCandidate({ candidate: nextCandidate, transaction, listing, shelvesIds })
      processedCandidates = [ ...processedCandidates, nextCandidate ]
    }
    await createItemsSequentially()
  }
</script>
<div class="import-candidates">
  {#if candidates.length > 0}
    <h3>4/ {I18n('import the selection')}</h3>
    <Flash bind:state={flash}/>
    {#if importingCandidates}
      <Counter count={processedEntitiesCount} total={candidates.length} message='creating bibliographical data'/>
      <Counter count={processedItemsCount} total={candidates.length} message='creating your books'/>
    {:else}
      <button
        class="button success"
        disabled={selectedCandidates.length === 0}
        title={selectedCandidates.length === 0 ? I18n('no book selected') : ''}
        on:click={importCandidates}
        >
        {I18n('create selected books')}
      </button>
    {/if}
  {/if}
  {#if processedCandidates.length > 0}
    <div bind:this={importResultsElement}>
      <ImportResults  {transaction} {listing} bind:processedCandidates/>
    </div>
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
