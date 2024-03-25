<script>
  import { pluck } from 'underscore'
  import Dropdown from '#components/dropdown.svelte'
  import Modal from '#components/modal.svelte'
  import Spinner from '#components/spinner.svelte'
  import EditionCreation from '#entities/components/layouts/edition_creation.svelte'
  import EntitiesList from '#entities/components/layouts/entities_list.svelte'
  import { icon } from '#lib/icons'
  import { onChange } from '#lib/svelte/svelte'
  import { showLoginPageAndRedirectHere } from '#lib/utils'
  import { userListings } from '#listings/lib/stores/user_listings'
  import ListingEditor from '#modules/listings/components/listing_editor.svelte'
  import { addElement, getUserListingsByEntityUri, removeElement } from '#modules/listings/lib/listings'
  import { I18n, i18n } from '#user/lib/i18n'
  import { getSubEntities } from '../lib/entities.ts'

  export let entity, editions, flash, align

  const { uri } = entity
  const { loggedIn } = app.user

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
      showListingCreationModal = false
      $userListings = $userListings.concat([ newListing ])
      listingsIdsMatchingUri = listingsIdsMatchingUri.concat([ newListing._id ])
      await addElement(newListing._id, uri)
    } catch (err) {
      flash = err
    }
  }

  async function fetchEditions () {
    if (!editions) {
      editions = await getSubEntities('work', entity.uri)
    }
  }

  let showListingCreationModal = false
  let showEditionPickerModal = false

  $: onChange(showEditionPickerModal, fetchEditions)
</script>

<div class="add-to-dot-dot-dot-menu">
  {#if loggedIn}
    <Dropdown
      {align}
      buttonTitle={i18n('Add this work to your inventory or to a list')}
      dropdownWidthBaseInEm={25}
    >
      <div slot="button-inner" class="add-to-dot-dot-dot-menu-button">
        <span>
          {@html icon('plus')}
          {i18n('Add to…')}
        </span>
        <span>
          {@html icon('caret-down')}
        </span>
      </div>
      <div slot="dropdown-content">
        <div class="menu-section">
          <span class="section-label">{i18n('Inventory')}</span>
          <button on:click={() => showEditionPickerModal = true}
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
            <div role="menu">
              {#each listings as listing}
                <div role="menuitem">
                  <label>
                    <input type="checkbox" checked={listing.checked} on:click={e => updateListing(e, listing)} />
                    {listing.name}
                  </label>
                </div>
              {/each}
              <div role="menuitem">
                <button on:click={() => showListingCreationModal = true}
                >
                  {@html icon('plus')}
                  {i18n('Create a new list')}
                </button>
              </div>
            </div>
          {/await}
        </div>
      </div>
    </Dropdown>
  {:else}
    <button
      class="require-login"
      title={i18n('Add this work to your inventory or to a list')}
      on:click={showLoginPageAndRedirectHere}
    >
      <span>
        {@html icon('plus')}
        {i18n('Add to…')}
      </span>
      <span>
        {@html icon('caret-down')}
      </span>
    </button>
  {/if}
</div>

{#if showListingCreationModal}
  <Modal on:closeModal={() => showListingCreationModal = false}
  >
    <ListingEditor
      layoutTitle={i18n('Create a new list')}
      on:listingEditorDone={e => addNewListing(e.detail)}
    />
  </Modal>
{/if}

{#if showEditionPickerModal}
  <Modal on:closeModal={() => showEditionPickerModal = false}
  >
    <h2>{i18n('Select an edition')}</h2>
    {#if editions.length > 0}
      <EntitiesList
        entities={editions}
        parentEntity={entity}
      />
    {:else}
      <p class="no-edition">{I18n('no editions found')}</p>
    {/if}
    <EditionCreation
      work={entity}
      bind:editions
    />
  </Modal>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .add-to-dot-dot-dot-menu{
    .require-login, :global(.dropdown-button){
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
      border-block-end: 1px solid #ddd;
    }
  }
  .section-label{
    color: $label-grey;
    margin: 0.5em;
  }
  [role="menu"]{
    max-block-size: 11em;
    overflow-y: auto;
  }
  [role="menuitem"]:not(:last-child){
    border-block-end: 1px solid #ddd;
  }
  button, label{
    inline-size: 100%;
    text-align: start;
    line-height: $tiny-button-line-height;
    @include tiny-button-padding;
    @include bg-hover(white, 5%);
  }
  label{
    font-size: 1rem;
    color: $default-text-color;
  }
  .no-edition{
    color: $label-grey;
  }
</style>
