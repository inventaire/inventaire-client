<script>
  import { I18n } from '#user/lib/i18n'
  export let candidates
  export let processing

  let externalShelves = []

  const groupExternalShelves = () => {
    candidates.forEach(candidate => {
      const { index, shelves } = candidate
      if (shelves) shelves.forEach(asssignOrCreateExternalShelves(index))
    })
  }

  const asssignOrCreateExternalShelves = candidateIndex => candidateShelf => {
    const alreadyNewShelf = externalShelves.find(importShelf => importShelf.name === candidateShelf)
    if (alreadyNewShelf) {
      alreadyNewShelf.candidatesIndexes.push(candidateIndex)
    } else {
      externalShelves.push({
        name: candidateShelf,
        candidatesIndexes: [ candidateIndex ]
      })
    }
  }

  $: { if (!processing) groupExternalShelves() }
</script>
<div class="importShelves">
  <label for="external-shelves-selector">
    <p class="title">{I18n('external_shelves_importer')}</p>
    <p class="description">{I18n('external_shelves_importer_description')}</p>
  </label>
  <div id="external-shelves-selector" class="select-button-group" role="menu">
    {#each externalShelves as externalShelf}
      {externalShelf.name}
    {/each}
  </div>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .import-shelves {
    margin: 1em 0;
  }
  .description{
    font-size: 0.9rem;
    margin-bottom: 0.5em;
  }
  .importShelves{
    margin: 1em 0
  }
</style>
