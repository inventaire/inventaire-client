<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import Spinner from '#general/components/spinner.svelte'
  import { getListingsByEntityUri } from '#listings/lib/listings'
  import ListingsLayout from '#modules/listings/components/listings_layout.svelte'

  export let entity, emptyListings
  let listings = []
  let noListingsFound

  const getListings = async () => {
    const { uri } = entity
    if (uri) {
      listings = await getListingsByEntityUri(uri) || []
    }
    noListingsFound = (listings.length === 0)
  }

  const waitingForListings = getListings()

  $: emptyListings = listings.length === 0
</script>

{#if !noListingsFound}
  <div class="listings-layout">
    <h5>{i18n('Lists containing this work')}</h5>
    {#await waitingForListings}
      <p class="loading">{I18n('loading')}<Spinner /></p>
    {:then}
      <ListingsLayout {listings} />
    {/await}
  </div>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .listings-layout{
    @include display-flex(column, center);
    background-color: $off-white;
    padding: 1em 0.5em;
    margin: 1em 0;
  }
  h5{
    @include sans-serif;
    margin-block-end: 0.5em;
  }
  .loading{
    @include display-flex(column, center);
  }
</style>
