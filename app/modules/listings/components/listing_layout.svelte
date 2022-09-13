<script>
  import { I18n } from '#user/lib/i18n'
  import ListingSelections from './listing_selections.svelte'
  import ListingInfoBox from '#modules/listings/components/listing_info_box.svelte'

  export let listing

  let { _id, creator, selections } = listing

  let isEditable = creator === app.user.id
</script>
<div class="listing-layout">
  <ListingInfoBox
    {listing}
    {isEditable}
  />
  <ListingSelections
    bind:selections
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
   @include display-flex(column, center);
 }
 .listing-id{
 	@include display-flex(column, center);
 	font-size: small;
 }
</style>
