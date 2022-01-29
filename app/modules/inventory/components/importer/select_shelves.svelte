<script>
  import { I18n } from 'modules/user/lib/i18n'
  import _ from 'underscore'
  import app from 'app/app'
  import Spinner from 'modules/general/components/spinner.svelte'
  import { getShelvesByOwner } from 'modules/shelves/lib/shelves'
  import SelectShelf from 'modules/inventory/components/importer/select_shelf.svelte'

  export let shelvesIds
  let userShelves = []

  const waitForShelves = getShelvesByOwner(app.user.id)
  .then(res => userShelves = res)

  $: shelvesIds = _.compact(userShelves.map(shelf => {
    if (shelf.checked) return shelf._id
  }))
</script>
{#await waitForShelves}
  <label for="shelves">{I18n('shelves')}</label>
  <Spinner/>
{:then}
  {#if userShelves.length > 0}
    <label for="shelves">{I18n('shelves')}</label>
    {#each userShelves as shelf}
      <SelectShelf bind:shelf/>
    {/each}
  {/if}
{/await}
