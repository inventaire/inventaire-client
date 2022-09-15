<script>
  import ListingLi from '#modules/listings/components/listing_li.svelte'
  import { i18n } from '#user/lib/i18n'

  export let listingsWithElements
</script>

<ul class="listings-layout">
  {#each listingsWithElements as listing}
    <ListingLi {listing} />
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
    max-height: 42em;
    overflow-y: auto;
  }
  .empty{
    color: $grey;
    text-align: center;
  }
</style>
