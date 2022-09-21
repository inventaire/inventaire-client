<script>
  import ListingLi from '#modules/listings/components/listing_li.svelte'
  import { i18n } from '#user/lib/i18n'

  export let listingsWithElements, onUserLayout = false
</script>

<ul class="listings-layout">
  {#each listingsWithElements as listing (listing._id)}
    <ListingLi {listing} {onUserLayout} />
  {/each}
  {#if listingsWithElements.length === 0}
    <li class="empty">
      {i18n('There is nothing here')}
    </li>
  {/if}
</ul>

<style lang="scss">
  @import '#general/scss/utils';
  .listings-layout{
    @include display-flex(row, center, center, wrap);
    overflow-y: auto;
  }
  .empty{
    color: $grey;
    text-align: center;
  }
</style>
