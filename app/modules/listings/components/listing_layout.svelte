<script lang="ts">
  import app from '#app/app'
  import type { SerializedUser } from '#app/modules/users/lib/users'
  import ListingInfoBox from '#modules/listings/components/listing_info_box.svelte'
  import type { ListingElement } from '#server/types/element'
  import type { ListingWithElements } from '#server/types/listing'
  import { I18n } from '#user/lib/i18n'
  import ListingElements from './listing_elements.svelte'

  export let listing: ListingWithElements
  export let initialElement: ListingElement = null
  export let creator: SerializedUser

  let { _id, elements } = listing

  const isEditable = creator._id === app.user.id
</script>
<div class="listing-layout">
  <ListingInfoBox
    {listing}
    {creator}
    {isEditable}
  />
  <ListingElements
    bind:elements
    {listing}
    {creator}
    {initialElement}
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
