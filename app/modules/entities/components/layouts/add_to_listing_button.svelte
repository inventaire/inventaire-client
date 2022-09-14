<script>
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import Dropdown from '#components/dropdown.svelte'
  import { userListings } from '#listings/lib/stores/user_listings'
  import { addElement, getUserListingsByEntityUri, removeElement } from '#modules/listings/lib/listings'
  import Spinner from '#components/spinner.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import { pluck } from 'underscore'

  export let entity, flash

  const { uri } = entity

  let listings, listingsIdsMatchingUri

  function refreshListings () {
    if (!listingsIdsMatchingUri) return
    listings = $userListings.map(listing => {
      listing.checked = listingsIdsMatchingUri.includes(listing._id)
      return listing
    })
  }

  $: onChange($userListings, listingsIdsMatchingUri, refreshListings)

  const waitingForListingsStates = getUserListingsByEntityUri({ userId: app.user.id, uri })
    .then(listingsMatchingUri => {
      listingsIdsMatchingUri = pluck(listingsMatchingUri, '_id')
    })
    .catch(err => flash = err)

  function updateListing (e, listing) {
    if (e.target.checked) {
      addElement(listing._id, uri)
    } else {
      removeElement(listing._id, uri)
    }
  }
</script>

<div class="add-to-listing-button">
  <Dropdown
    alignDropdownWidthOnButton={true}
  >
    <div slot="button-inner">
      {@html icon('list')}
      {i18n('Add to a list')}
    </div>
    <div slot="dropdown-content">
      {#await waitingForListingsStates}
        <Spinner center={true} />
      {:then}
        <ul role="menu">
          {#each listings as listing}
            <li>
              <label>
                <input type="checkbox" checked={listing.checked} on:click={e => updateListing(e, listing)}>
                {listing.name}
              </label>
            </li>
          {/each}
          <li>
            <button
              on:click={() => alert('TODO: show a modal to create a new list')}
            >
              {@html icon('plus')}
              {i18n('Create a new list')}
            </button>
          </li>
        </ul>
      {/await}
    </div>
  </Dropdown>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .add-to-listing-button{
    :global(.dropdown-button){
      @include tiny-button($green-tree);
    }
  }
  [slot="dropdown-content"]{
    background-color: white;
    @include shy-border;
    @include display-flex(column, stretch);
    @include radius;
    overflow: hidden;
  }
  li:not(:last-child){
    border-bottom: 1px solid #ddd;
  }
  button, label{
    width: 100%;
    text-align: start;
    line-height: $tiny-button-line-height;
    @include tiny-button-padding;
    @include bg-hover(white, 5%);
  }
  label{
    font-size: 1rem;
    color: $default-text-color;
  }
</style>
