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
  <div class="listings-layout listings-comments-layout" class:empty={listingsWithEntityComment.length === 0}>
    <h5>{i18n('Comments')}</h5>
    {#if listingsWithEntityComment.length === 0}
      <p class="empty">
        {i18n('There is nothing here')}
      </p>
    {:else}
      <ul class="listings-list">
        {#each listingsWithEntityComment as listing (listing._id)}
          <EntityListingComment {listing} {uri} />
        {/each}
      </ul>
    {/if}
  </div>
  <div class="listings-layout listings-without-comments-layout" class:empty={listingsWithoutEntityComment.length === 0}>
    <h5>{i18n('Lists')}</h5>
    {#if listingsWithoutEntityComment.length === 0}
      <p class="empty">
        {i18n('There is nothing here')}
      </p>
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
    padding: 0.5em;
  }
  .listings-layout{
    background-color: $off-white;
    margin: auto;
    &.empty{
      @include display-flex(row, center, space-between);
    }
    &:not(.empty){
      h5{
        margin-block-end: 1em;
      }
    }
  }
  .listings-list{
    width: 100%;
  }
  h5{
    @include sans-serif;
    margin: 0;
  }
  .loading{
    @include display-flex(column, center);
  }
  p.empty{
    color: $grey;
    text-align: center;
  }
</style>
