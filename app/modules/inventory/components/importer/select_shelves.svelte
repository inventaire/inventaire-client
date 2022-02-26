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
  <label for="shelves-selector">
    <p class="title">{I18n('shelves')}</p>
    <p class="description">{I18n('shelves_importer_description')}</p>
  </label>
  <Spinner/>
{:then}
  {#if userShelves.length > 0}
    <label for="shelves-selector">
      <p class="title">{I18n('shelves')}</p>
      <p class="description">{I18n('shelves_importer_description')}</p>
      <!-- i18n suggestion: "shelves_importer_description": "Add the selected books to your shelf(ves)" -->
    </label>
    <ul id="shelves-selector" class="select-button-group" role="menu">
      {#each userShelves as shelf}
        <SelectShelf bind:shelf/>
      {/each}
    </ul>
  {/if}
{/await}
<style>
  .description{
    font-size: 0.9rem;
    margin-bottom: 0.5em;
  }
</style>
