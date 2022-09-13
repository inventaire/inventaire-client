<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import ListingLi from './listing_li.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { getListingsByEntityUri } from '#listings/lib/listings'

  export let entity, emptyListings
  let listings = []

  const getListings = async () => {
    const { uri } = entity
    if (uri) {
      listings = await getListingsByEntityUri(uri) || []
    }
  }

  const waitingForLists = getListings()

  $: emptyListings = listings.length === 0
</script>

<div class="listings-layout">
  <h5>
    {I18n('lists with this entityType', { entityType: entity.type })}
  </h5>
  <div class="listings">
    {#await waitingForLists}
      <p class="loading">{I18n('loading')}<Spinner/></p>
    {:then}
      {#each listings as listing}
        <ListingLi {listing} />
      {/each}
      {#if emptyListings}
        <div class="no-listings">
          {i18n('There is nothing here')}
        </div>
      {/if}
    {/await}
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .listings-layout{
    @include display-flex(column, center);
    background-color: $off-white;
    padding: 1em 0.5em;
    margin: 1em 0;
  }
  h5{
    @include sans-serif;
    margin-bottom: 0.5em;
  }
  .listings{
    @include display-flex(row, center);
    max-height: 42em;
    overflow-y: auto;
  }
  .loading{
    @include display-flex(column, center);
  }
  .no-listings{
    @include display-flex(row, center, center);
    color: $grey;
    margin-top: 1em;
  }
  /*Very small screens*/
  @media screen and (max-width: 700px) {
    .listings{
      @include display-flex(column, center);
    }
  }
</style>
