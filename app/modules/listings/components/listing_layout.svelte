<script>
  import { I18n } from '#user/lib/i18n'
  import ListingElements from './listing_elements.svelte'
  import ListingInfoBox from '#modules/listings/components/listing_info_box.svelte'

  export let listing

  let { _id, creator, elements } = listing

  let isEditable = creator === app.user.id
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
  @import '#general/scss/utils';
 .listing-layout{
    max-width: 50em;
    margin: 0 auto;
    @include display-flex(column, center);
 }
 .listing-id{
 	@include display-flex(column, center);
 	font-size: small;
 }
</style>
