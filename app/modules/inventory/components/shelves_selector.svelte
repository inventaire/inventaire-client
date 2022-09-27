<script>
  import { I18n } from '#user/lib/i18n'
  import app from '#app/app'
  import Spinner from '#components/spinner.svelte'
  import { getShelvesByOwner } from '#shelves/lib/shelves'
  import ShelfInfo from '#inventory/components/shelf_info.svelte'
  import { pluck } from 'underscore'

  export let shelvesIds
  export let showDescription = false
  let userShelves = []

  const waitForShelves = getShelvesByOwner(app.user.id)
    .then(res => {
      userShelves = res
      const userShelvesIds = pluck(userShelves, '_id')
      // Filter-out any shelf that might have been deleted
      // but passed as it was saved by `app.execute('last:shelves:set')`
      shelvesIds = shelvesIds.filter(id => userShelvesIds.includes(id))
    })
</script>

<fieldset>
  {#await waitForShelves}
    <Spinner/><span class="title">{I18n('shelves')}</span>
  {:then}
    {#if userShelves.length > 0}
      <legend>
        <p class="title">{I18n('shelves')}</p>
        {#if showDescription}
          <p class="description">{I18n('shelves_importer_description')}</p>
        {/if}
        <!-- i18n suggestion: "shelves_importer_description": "Add the selected books to your shelf(ves)" -->
      </legend>
      {#each userShelves as shelf}
        <label title={I18n('select_shelf')}>
          <input type="checkbox" bind:group={shelvesIds} value={shelf._id}>
          <ShelfInfo bind:shelf />
        </label>
      {/each}
    {/if}
  {/await}
</fieldset>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#inventory/scss/shelves_selectors';
</style>
