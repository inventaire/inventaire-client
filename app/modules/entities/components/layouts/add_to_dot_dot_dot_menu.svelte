<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import Dropdown from '#components/dropdown.svelte'
  import { userListings } from '#listings/lib/stores/user_listings'
  import { addElement, getUserListingsByEntityUri, removeElement } from '#modules/listings/lib/listings'
  import Spinner from '#components/spinner.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import { pluck } from 'underscore'
  import Modal from '#components/modal.svelte'
  import ListingCreator from '#modules/listings/components/listing_creator.svelte'
  import EntitiesList from '#entities/components/layouts/entities_list.svelte'

  export let entity, editions, flash

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

  async function updateListing (e, listing) {
    try {
      if (e.target.checked) {
        await addElement(listing._id, uri)
      } else {
        await removeElement(listing._id, uri)
      }
    } catch (err) {
      flash = err
    }
  }

  async function addNewListing (newListing) {
    try {
      showListCreationModal = false
      $userListings = $userListings.concat([ newListing ])
      listingsIdsMatchingUri = listingsIdsMatchingUri.concat([ newListing._id ])
      await addElement(newListing._id, uri)
    } catch (err) {
      flash = err
    }
  }

  let showListCreationModal = false
  let showEditionPickerModal = false
</script>

<div class="add-to-dot-dot-dot-menu">
  <Dropdown>
    <div slot="button-inner">
      <span>
        {@html icon('plus')}
        {i18n('Add to...')}
      </span>
      <span>
        {@html icon('caret-down')}
      </span>
    </div>
    <div slot="dropdown-content">
      <div class="menu-section">
        <span class="section-label">{i18n('Inventory')}</span>
        <button
          on:click={() => showEditionPickerModal = true}
        >
          {@html icon('plus')}
          {I18n('select the edition to add to my inventory')}
        </button>
      </div>
      <div class="menu-section">
        <span class="section-label">{i18n('Lists')}</span>
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
                on:click={() => showListCreationModal = true}
              >
                {@html icon('plus')}
                {i18n('Create a new list')}
              </button>
            </li>
          </ul>
        {/await}
      </div>
    </div>
  </Dropdown>
</div>

{#if showListCreationModal}
  <Modal
    on:closeModal={() => showListCreationModal = false}
  >
    <ListingCreator on:newListing={e => addNewListing(e.detail)} />
  </Modal>
{/if}

{#if showEditionPickerModal}
  <Modal
    on:closeModal={() => showEditionPickerModal = false}
  >
  <h2>{i18n('Select an edition')}</h2>
  <EntitiesList
    entities={editions}
    parentEntity={entity}
  />
  </Modal>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .add-to-dot-dot-dot-menu{
    :global(.dropdown-button){
      @include tiny-button($light-blue);
    }
  }
  [slot="button-inner"]{
    @include display-flex(row, center, space-between);
  }
  [slot="dropdown-content"]{
    background-color: $off-white;
    @include shy-border;
    @include display-flex(column, stretch);
    @include radius;
    overflow: hidden;
  }
  .menu-section{
    @include display-flex(column, stretch);
    &:not(:last-child){
      border-bottom: 1px solid #ddd;
    }
  }
  .section-label{
    color: $label-grey;
    margin: 0.5em;
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
