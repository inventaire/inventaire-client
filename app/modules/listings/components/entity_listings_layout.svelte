<script lang="ts">
  import Spinner from '#general/components/spinner.svelte'
  import { getListingsByEntityUri } from '#listings/lib/listings'
  import EntityListingComment from '#modules/listings/components/entity_listing_comment.svelte'
  import { i18n, I18n } from '#user/lib/i18n'

  export let entity

  let listings = []
  const { uri } = entity

  const getListings = async () => {
    if (uri) {
      listings = await getListingsByEntityUri(uri) || []
    }
  }

  const waitingForListings = getListings()
</script>

{#await waitingForListings}
  <p class="loading">{I18n('loading')}<Spinner /></p>
{:then}
  <div class="listings-layout listings-comments-layout">
    <h5>{i18n('Comments from lists containing this work')}</h5>
    {#if listingsWithEntityComment.length === 0}
      <div class="empty">
        {i18n('There is nothing here')}
      </div>
    {:else}
      <ul class="listings-list">
        {#each listings as listing (listing._id)}
          <EntityListingComment {listing} {uri} />
        {/each}
      </ul>
    {/if}
  {/await}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .listings-list{
    width: 100%;
  }
  .listings-layout{
    @include display-flex(column, center);
    background-color: $off-white;
    padding: 0.5em;
    margin: auto;
    inline-size: 100%;
    max-width: 40em;
  }
  h5{
    @include sans-serif;
    margin-block-end: 0;
  }
  .loading{
    @include display-flex(column, center);
  }
  .empty{
    color: $grey;
    text-align: center;
  }
</style>
