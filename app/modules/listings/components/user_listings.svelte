<script>
  import ListingCreator from '#modules/listings/components/listing_creator.svelte'
  import { getListingsByCreator, serializeListing } from '#modules/listings/lib/listings'
  import { i18n, I18n } from '#user/lib/i18n'
  import { loadInternalLink } from '#lib/utils'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'

  export let user

  let listings, flash

  const waitingForListings = getListingsByCreator(user._id)
    .then(res => listings = res.listings.map(serializeListing))
    .catch(err => flash = err)

  const isMainUser = user._id === app.user.id
  let newListing = {}

  $: if (newListing._id) {
    listings = listings.concat([ serializeListing(newListing) ])
    newListing = {}
  }
</script>

<div class="listings-layout">
  <h3 class="subheader">{I18n('lists')}</h3>

  {#await waitingForListings}
    <Spinner />
  {:then}
    <ul>
      {#each listings as listing}
        <li>
          <a href={listing.pathname} on:click={loadInternalLink}>
            {listing.name}
          </a>
        </li>
      {/each}
      {#if listings.length === 0}
        <li class="empty">
          {i18n('There is nothing here')}
        </li>
      {/if}
    </ul>
    {#if isMainUser}
      <div class="menu">
        <ListingCreator bind:listing={newListing} />
      </div>
    {/if}
  {/await}

  <Flash state={flash} />
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .listings-layout{
    background-color: $light-grey;
    margin: 1em;
    padding: 0.5em;
  }
  h3{
    font-size: 1rem;
    @include sans-serif;
  }
  li a{
    display: block;
    @include bg-hover(darken($light-grey, 5%));
    padding: 0.5em;
    margin: 0.2em;
    @include radius;
  }
  .empty{
    color: $grey;
    text-align: center;
  }
  .menu{
    margin-top: 1em;
    @include display-flex(row, center, flex-end);
  }
</style>
