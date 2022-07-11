<script>
  import { I18n } from '#user/lib/i18n'
  import app from '#app/app'
  import Spinner from '#components/spinner.svelte'
  import { getShelvesByOwner } from '#shelves/lib/shelves'
  import ShelfInfo from '#inventory/components/importer/select_info.svelte'

  export let shelvesIds
  let userShelves = []

  const waitForShelves = getShelvesByOwner(app.user.id)
    .then(res => userShelves = res)
</script>

<div class="shelves-selector">
  {#await waitForShelves}
    <Spinner/><span class="title">{I18n('shelves')}</span>
  {:then}
    {#if userShelves.length > 0}
      <fieldset>
        <legend>
          <p class="title">{I18n('shelves')}</p>
          <p class="description">{I18n('shelves_importer_description')}</p>
          <!-- i18n suggestion: "shelves_importer_description": "Add the selected books to your shelf(ves)" -->
        </legend>
        {#each userShelves as shelf}
          <label title={I18n('select_shelf')}>
            <input type="checkbox" bind:group={shelvesIds} value={shelf._id}>
            <ShelfInfo bind:shelf />
          </label>
        {/each}
      </fieldset>
    {/if}
  {/await}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .description{
    font-size: 0.9rem;
    margin-bottom: 0.5em;
  }
  legend{
    max-height: 15em;
    overflow: auto;
  }
  .shelves-selector{
    margin-top: 1em;
  }
  label{
    color: $default-text-color;
    @include bg-hover($off-white, 5%);
    @include display-flex(row, center, flex-start);
    @include radius;
    cursor: pointer;
    margin-bottom: 0.1em;
  }
  input[type="checkbox"]{
    margin: 0.5em;
  }
</style>
