<script lang="ts">
  import Spinner from '#general/components/spinner.svelte'
  import { getListingsByEntityUri } from '#listings/lib/listings'
  import EntityListingComment from '#modules/listings/components/entity_listing_comment.svelte'
  import { i18n, I18n } from '#user/lib/i18n'

  export let entity
  export let emptyListings = false

  let listings = []
  let noListingsFound
  const { uri } = entity

  const getListings = async () => {
    if (uri) {
      listings = await getListingsByEntityUri(uri) || []
    }
    noListingsFound = (listings.length === 0)
  }

  const waitingForListings = getListings()

  $: emptyListings = listings.length === 0
</script>

<div class="listings-layout">
  <h5>{i18n('Lists containing this work')}</h5>
  {#await waitingForListings}
    <p class="loading">{I18n('loading')}<Spinner /></p>
  {:then}
    {#if noListingsFound}
      <div class="empty">
        {i18n('There is nothing here')}
      </div>
    {:else}
      <ul class="listings-layout">
        {#each listings as listing (listing._id)}
          <EntityListingComment {listing} {uri} />
        {/each}
      </ul>
    {/if}
  {/await}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .listings-layout{
    @include display-flex(column, center);
    background-color: $off-white;
    padding: 1em 0.5em;
    margin: auto;
    inline-size: 100%;
    max-width: 50em;
  }
  h5{
    @include sans-serif;
    margin-block-end: 0.5em;
  }
  .loading{
    @include display-flex(column, center);
  }
  .empty{
    color: $grey;
    text-align: center;
  }
</style>
