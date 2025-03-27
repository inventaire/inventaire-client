<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import app from '#app/app'
  import { isNonEmptyArray, isNonEmptyPlainObject } from '#app/lib/boolean_tests'
  import { autofocus } from '#app/lib/components/actions/autofocus'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { onChange } from '#app/lib/svelte/svelte'
  import Dropdown from '#components/dropdown.svelte'
  import EntityImage from '#entities/components/entity_image.svelte'
  import AuthorsInfo from '#entities/components/layouts/authors_info.svelte'
  import Ebooks from '#entities/components/layouts/ebooks.svelte'
  import EntityTitle from '#entities/components/layouts/entity_title.svelte'
  import Infobox from '#entities/components/layouts/infobox.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import { authorsProps } from '#entities/components/lib/claims_helpers'
  import type { SerializedEntity } from '#entities/lib/entities'
  import { entitiesTypesByListingType } from '#listings/lib/entities_typing'
  import { updateElement } from '#listings/lib/listings'
  import { userListings } from '#listings/lib/stores/user_listings'
  import ListingElementComment from '#modules/listings/components/listing_element_comment.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import type { SerializedUser } from '#users/lib/users'
  import type { ListingElementWithEntity } from '../lib/listings'

  export let element: ListingElementWithEntity
  export let entity: SerializedEntity
  export let isCreatorMainUser: boolean
  export let creator: SerializedUser

  const dispatch = createEventDispatcher()
  $: ({ claims, type: entityType } = entity)

  let flash, recipientListings

  function getRecipientListings () {
    recipientListings = $userListings.filter(canListingReceiveElement)
  }

  function canListingReceiveElement (listing) {
    // legacy: old lists may not have any type, therefore type must be set to default "work"
    const listingType = listing.type || 'work'
    const allowlistedEntitiesTypes = entitiesTypesByListingType[listingType]
    return allowlistedEntitiesTypes.includes(entityType) && (listing._id !== element.list)
  }

  async function updateElementListing (listingId) {
    await updateElement({
      id: element._id,
      list: listingId,
    })
      .then(() => {
        app.navigateAndLoad(`/lists/${listingId}/element/${element._id}`)
      })
      .catch(err => {
        flash = err
      })
  }
  $: onChange($userListings, getRecipientListings)
</script>

<div class="listing-element-show">
  <div class="entity-type-label">
    {I18n(entityType)}
  </div>
  <EntityTitle
    {entity}
    hasLinkTitle={true}
  />

  {#if element.comment || isCreatorMainUser}
    <ListingElementComment
      {isCreatorMainUser}
      {creator}
      bind:element
      bind:flash
    />
  {/if}

  <div class="entity-info-row">
    {#if isNonEmptyPlainObject(entity.image)}
      <EntityImage
        {entity}
        size={192}
      />
    {/if}
    <div class="entity-infobox">
      <AuthorsInfo {claims} />
      <Infobox
        {claims}
        {entityType}
        shortlistOnly={true}
        omittedProperties={authorsProps}
      />
      <Ebooks {entity} />
    </div>
  </div>

  <Summary {entity} />

  {#if isCreatorMainUser}
    <div class="buttons-wrapper">
      {#if isNonEmptyArray(recipientListings)}
        <Dropdown
          buttonTitle={i18n('Move element to another list')}
          dropdownWidthBaseInEm={25}
          clickOnContentShouldCloseDropdown={true}
        >
          <div
            slot="button-inner"
            class="element-button"
          >
            <span>
              {@html icon('arrow-right')}
              {i18n('Move element to another list')}
            </span>
            <span>
              {@html icon('caret-down')}
            </span>
          </div>
          <div slot="dropdown-content">
            <div class="menu-section">
              <ul role="menu" use:autofocus>
                {#each recipientListings as recipientListing}
                  <li>
                    <button
                      role="menuitem"
                      on:click={() => updateElementListing(recipientListing._id)}
                    >
                      {recipientListing.name}
                    </button>
                  </li>
                {/each}
              </ul>
            </div>
          </div>
        </Dropdown>
      {/if}
      <button
        class="element-button remove-button"
        on:click={() => dispatch('removeElement', element)}
      >
        {@html icon('trash')}
        <span>{I18n('remove element')}</span>
      </button>
    </div>
  {/if}
</div>

<Flash bind:state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  .listing-element-show{
    min-width: 40em;
    /* Very small screens */
    @media screen and (width < $smaller-screen){
      min-width: 100%;
    }
  }
  .entity-type-label{
    color: $soft-grey;
    text-align: center;
  }
  .entity-info-row{
    display: flex;
    margin: 2em 0;
    :global(.image-div){
      margin-inline-end: 1em;
    }
  }
  .entity-infobox{
    margin: 0 1em;
    flex: 2;
  }
  .buttons-wrapper{
    @include display-flex(row, center, space-between);
    margin-block-start: 1.5em;
  }
  :global(.dropdown-content){
    @include radius;
  }
  .element-button{
    min-width: 10rem;
    padding: 0.4em 0.6em;
    @include shy(0.6);
    :global(.fa){
      font-size: 1.1em;
    }
    &:hover, &:focus{
      border-radius: $global-radius;
      background-color: $light-grey;
    }
  }
  .remove-button{
    &:hover, &:focus{
      background-color: $danger-color;
    }
  }
  [role="menu"] button{
    @include shy-border;
    @include tiny-button-padding;
    @include bg-hover(white, 5%);
    padding: .3em 1em;
    inline-size: 100%;
    text-align: start;
    line-height: $tiny-button-line-height;
  }
  /* Smaller screens */
  @media screen and (width < $smaller-screen){
    .entity-info-row{
      @include display-flex(column, center);
      :global(.image-div){
        margin-block-end: 1em;
      }
    }
  }
</style>
