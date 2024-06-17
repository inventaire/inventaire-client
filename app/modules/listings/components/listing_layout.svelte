<script lang="ts">
  import app from '#app/app'
  import ListingInfoBox from '#modules/listings/components/listing_info_box.svelte'
  import { I18n } from '#user/lib/i18n'
  import ListingElements from './listing_elements.svelte'

  export let listing

  let { _id, creator, elements } = listing

  const isEditable = creator === app.user.id
</script>
<div class="listing-layout">
  <ListingInfoBox
    {listing}
    {isEditable}
  />
  <ListingElements
    bind:elements
    listingId={_id}
    {isEditable}
  />
</div>

<div class="footer">
  <p class="listing-id">
    {I18n('list')}
    -
    {_id}
  </p>
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .listing-layout{
    max-width: 40em;
    margin: 0 auto;
    @include display-flex(column, center);
  }
  .listing-id{
    @include display-flex(column, center);
    font-size: small;
  }
</style>
