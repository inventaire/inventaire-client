<script>
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import ListingsLayout from '#modules/listings/components/listings_layout.svelte'
  import ListingCreator from '#modules/listings/components/listing_creator.svelte'
  import { getListingsByCreator, serializeListing } from '#modules/listings/lib/listings'

  export let user

  let listings, flash

  const waitingForListings = getListingsByCreator(user._id, true)
    .then(res => listings = res.listings.map(serializeListing))
    .catch(err => flash = err)

  const isMainUser = user._id === app.user.id
  let newListing = {}

  $: if (newListing._id) {
    listings = [ serializeListing(newListing), ...listings ]
    newListing = {}
  }
</script>

<div class="user-listings-layout">
  {#await waitingForListings}
    <Spinner />
  {:then}
    {#if isMainUser}
      <ListingCreator bind:listing={newListing} />
    {/if}
    <ListingsLayout listingsWithElements={listings} />
  {/await}
  <Flash state={flash} />
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .user-listings-layout{
    margin: 0 auto;
    background-color: white;
    max-width: 60em;
    padding: 0.5em;
  }
</style>
