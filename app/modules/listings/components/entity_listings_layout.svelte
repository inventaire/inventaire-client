<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import Spinner from '#general/components/spinner.svelte'
  import { getListingsByEntityUri } from '#listings/lib/listings'
  import ListingsLayout from '#modules/listings/components/listings_layout.svelte'

  export let entity, emptyListings
  let listings = []

  const getListings = async () => {
    const { uri } = entity
    if (uri) {
      listings = await getListingsByEntityUri(uri) || []
    }
  }

  const waitingForListings = getListings()

  $: emptyListings = listings.length === 0
</script>

<div class="listings-layout">
  <h5>{i18n('Lists containing this work')}</h5>
  {#await waitingForListings}
    <p class="loading">{I18n('loading')}<Spinner /></p>
  {:then}
    <ListingsLayout listingsWithElements={listings} />
  {/await}
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
  .loading{
    @include display-flex(column, center);
  }
</style>
