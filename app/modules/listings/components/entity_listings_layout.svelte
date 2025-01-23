<script lang="ts">
  import Spinner from '#general/components/spinner.svelte'
  import { getListingsByEntityUri } from '#listings/lib/listings'
  import EntityListing from '#modules/listings/components/entity_listing.svelte'
  import EntityListingComment from '#modules/listings/components/entity_listing_comment.svelte'
  import type { ListingWithElements } from '#server/types/listing'
  import { i18n, I18n } from '#user/lib/i18n'

  export let entity

  const { uri } = entity
  const listingsWithEntityComment = []
  const listingsWithoutEntityComment = []

  const getListings = async () => {
    if (uri) {
      const listings: ListingWithElements[] = await getListingsByEntityUri(uri) || []
      for (const listing of listings) {
        if (listing.elements.find(el => el.uri === uri).comment) {
          listingsWithEntityComment.push(listing)
        } else {
          listingsWithoutEntityComment.push(listing)
        }
      }
    }
  }

  const waitingForListings = getListings()
</script>

{#await waitingForListings}
  <p class="loading">{I18n('loading')}<Spinner /></p>
{:then}
  <div class="listings-layout listings-comments-layout">
    <h5>{i18n('Comments about this')}</h5>
    {#if listingsWithEntityComment.length === 0}
      <div class="empty">
        {i18n('There is nothing here')}
      </div>
    {:else}
      <ul class="listings-list">
        {#each listingsWithEntityComment as listing (listing._id)}
          <EntityListingComment {listing} {uri} />
        {/each}
      </ul>
    {/if}
  </div>
  <div class="listings-layout listings-without-comments-layout">
    <h5>{i18n('User lists about this')}</h5>
    {#if listingsWithoutEntityComment.length === 0}
      <div class="empty">
        {i18n('There is nothing here')}
      </div>
    {:else}
      <ul class="listings-list">
        {#each listingsWithoutEntityComment as listing (listing._id)}
          <EntityListing {listing} />
        {/each}
      </ul>
    {/if}
  </div>
{/await}

<style lang="scss">
  @import "#general/scss/utils";
  .listings-comments-layout{
    padding: 0.5em;
  }
  .listings-without-comments-layout{
    padding: 1em;
    h5{
      margin-block-end: 1em;
    }
  }
  .listings-layout{
    @include display-flex(column, center);
    background-color: $off-white;
    margin: auto;
    inline-size: 100%;
    max-width: 40em;
  }
  .listings-list{
    width: 100%;
  }
  h5{
    @include sans-serif;
  }
  .loading{
    @include display-flex(column, center);
  }
  .empty{
    color: $grey;
    text-align: center;
  }
</style>
