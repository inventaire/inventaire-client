<script>
  import { I18n } from '#user/lib/i18n'
  import _ from 'underscore'
  import app from '#app/app'
  import Spinner from '#components/spinner.svelte'
  import { getShelvesByOwner } from '#shelves/lib/shelves'
  import SelectShelf from '#inventory/components/importer/select_shelf.svelte'

  export let shelvesIds
  let userShelves = []

  const waitForShelves = getShelvesByOwner(app.user.id)
  .then(res => userShelves = res)

  $: shelvesIds = _.compact(userShelves.map(shelf => {
    if (shelf.checked) return shelf._id
  }))
</script>
{#await waitForShelves}
  <h4 for="shelves">{I18n('shelves')}</h4>
  <Spinner/>
{:then}
  {#if userShelves.length > 0}
    <h4 for="shelves">{I18n('shelves')}</h4>
    <label for="shelves">{I18n('shelves_importer_description')}</label>
    {#each userShelves as shelf}
      <SelectShelf bind:shelf/>
    {/each}
  {/if}
{/await}
<style>
  label{
    font-size: 1em;
    margin-bottom: 1em;
  }
  h4, label{
    text-align: center;
  }
</style>