<script>
  import { property } from 'underscore'
  import Counter from '#components/counter.svelte'
  import ImportResults from '#inventory/components/importer/import_results.svelte'
  import { createItemFromCandidate } from '#inventory/components/importer/lib/create_item'
  import { isAlreadyResolved, removeCreatedCandidates } from '#inventory/components/importer/lib/import_items_helpers'
  import { resolveAndCreateCandidateEntities } from '#inventory/lib/importer/import_helpers'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import Flash from '#lib/components/flash.svelte'
  import { scrollToElement } from '#lib/screen'
  import { addItemsByIdsToShelf, createShelf, getShelvesByOwner } from '#shelves/lib/shelves'
  import { I18n } from '#user/lib/i18n'

  export let candidates
  export let transaction
  export let visibility
  export let shelvesIds
  export let externalShelves

  let flash, shelvesFlash
  let importingCandidates
  let processedCandidates = []
  let processedItemsCount = 0
  let processedEntitiesCount = 0
  let importResultsElement
  let processedExternalShelvesCount = 0
  let externalShelfErrors = []

  $: selectedCandidates = candidates.filter(property('checked'))

  const importCandidates = async () => {
    flash = null
    try {
      importingCandidates = true
      processedEntitiesCount = 0
      await createEntitiesSequentially()
      processedItemsCount = 0
      await createItemsSequentially()
      processedExternalShelvesCount = 0
      await createExternalShelvesSequentially()
      importingCandidates = false
      candidates = removeCreatedCandidates({ candidates, processedCandidates })
      if (importResultsElement) scrollToElement(importResultsElement)
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
        const candidateWithEntities = await resolveAndCreateCandidateEntities(nextCandidate)
        candidates[candidatePosition] = candidateWithEntities
      }
    } catch (err) {
      // Do not throw to not crash the whole chain
      // Let the candidate_row display candidate specific errors
      nextCandidate.error = err
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
      await createItemFromCandidate({ candidate: nextCandidate, transaction, visibility, shelvesIds })
      processedCandidates = [ ...processedCandidates, nextCandidate ]
    }
    await createItemsSequentially()
  }

  const createExternalShelvesSequentially = async () => {
    const currentPosition = processedExternalShelvesCount
    const nextExternalShelf = externalShelves[currentPosition]
    if (!nextExternalShelf) return
    processedExternalShelvesCount += 1
    try {
      const newShelfId = await createAndAssignShelf(nextExternalShelf)
      if (newShelfId) {
        externalShelves[currentPosition] = Object.assign(nextExternalShelf, { invId: newShelfId })
      }
    } catch (err) {
      // Do not throw to not crash the whole chain
      const { responseJSON } = err
      const shelfError = I18n('shelf could not be created', nextExternalShelf.name)
      const shelfErrorMessage = `${shelfError} (${responseJSON.status_verbose}).`
      externalShelfErrors = [ ...externalShelfErrors, shelfErrorMessage ]
      shelvesFlash = { type: 'error', message: externalShelfErrors.join(' ') }
    }
    await createExternalShelvesSequentially()
  }

  let mainUserShelves
  const getExistingShelfOrCreateShelf = async ({ name, itemsIds }) => {
    mainUserShelves = mainUserShelves || await getShelvesByOwner(app.user.id)
    const matchingShelf = mainUserShelves.find(shelf => shelf.name === name)
    if (matchingShelf) {
      await addItemsByIdsToShelf({ shelfId: matchingShelf._id, itemsIds })
      return matchingShelf
    } else {
      const newShelf = await createShelf({
        name,
        items: itemsIds,
        // Set default visibility to private, as a selector would overcrowed the current interface
        // Users may edit shelf visibility settings later
        visibility: [],
      })
      return newShelf
    }
  }

  const createAndAssignShelf = async externalShelf => {
    assignItemsIdsToShelf(externalShelf)
    const { itemsIds, checked } = externalShelf
    if (checked && isNonEmptyArray(itemsIds)) {
      const shelf = await getExistingShelfOrCreateShelf({
        name: externalShelf.name,
        itemsIds,
      })
      if (shelf) return shelf._id
    }
  }

  const assignItemsIdsToShelf = shelf => {
    const itemsIds = []
    shelf.candidatesIndexes.forEach(candidateIndex => {
      const candidate = candidates.find(candidate => candidate.index === candidateIndex)
      if (candidate && candidate.checked) {
        const itemId = candidate.item?._id
        if (itemId) itemsIds.push(itemId)
      }
    })
    Object.assign(shelf, { itemsIds })
  }
</script>
<div class="import-candidates">
  {#if candidates.length > 0}
    <h3>4/ {I18n('import the selection')}</h3>
    <Flash bind:state={flash} />
    {#if importingCandidates}
      <Counter count={processedEntitiesCount} total={candidates.length} message="creating bibliographical data" />
      <Counter count={processedItemsCount} total={candidates.length} message="creating your books" />
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
      <ImportResults {transaction} {visibility} bind:processedCandidates />
    </div>
    <Flash bind:state={shelvesFlash} />
  {/if}
</div>
<style lang="scss">
  @import "#general/scss/utils";
  h3{
    margin-block-start: 1em;
    text-align: center;
    font-weight: bold;
  }
  .import-candidates{
    @include display-flex(column, center, null, wrap);
    button{ margin: 1em 0; }
  }
  button:disabled{
    opacity: 0.6;
  }
</style>
