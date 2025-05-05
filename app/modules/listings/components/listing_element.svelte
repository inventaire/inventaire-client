<script lang="ts">
  import app from '#app/app'
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import Flash, { type FlashState } from '#app/lib/components/flash.svelte'
  import { userContent } from '#app/lib/user_content'
  import { isOpenedOutside } from '#app/lib/utils'
  import ImageDiv from '#components/image_div.svelte'
  import Modal from '#components/modal.svelte'
  import AuthorsInline from '#entities/components/layouts/authors_inline.svelte'
  import { formatYearClaim } from '#entities/components/lib/claims_helpers'
  import { getEntityImagePath } from '#entities/lib/entities'
  import { getListingMetadata, getListingPathname, getElementPathname, getElementMetadata, removeElement, askUserConfirmationAndRemove, type ListingElementWithEntity } from '#listings/lib/listings'
  import ListingElementShow from '#modules/listings/components/listing_element_show.svelte'
  import type { ListingElement } from '#server/types/element'
  import type { Listing } from '#server/types/listing'
  import { i18n } from '#user/lib/i18n'
  import type { SerializedUser } from '#users/lib/users'
  import ListingElementActions from './listing_element_actions.svelte'

  export let element: ListingElementWithEntity
  export let listing: Listing
  export let elements: ListingElement[]
  export let showInitialElementModal: boolean
  export let isEditable: boolean
  export let isCreatorMainUser: boolean
  export let autocompleteFlash: FlashState
  export let creator: SerializedUser

  const { _id: listingId } = listing
  const { entity, _id: elementId } = element
  const { uri, label, claims, image } = entity
  const publicationYear = formatYearClaim('wdt:P577', claims)[0]
  const authorsUris = claims['wdt:P50']

  let imageUrl, flash
  let showElementModal = showInitialElementModal
  showInitialElementModal = false

  if (isNonEmptyArray(image)) {
    // This is the case when the entity object is a search result object
    imageUrl = getEntityImagePath(image[0])
  } else if (image?.url) {
    imageUrl = image.url
  }

  function toggleShowMode (e) {
    if (e && isOpenedOutside(e)) return
    showElementModal = !showElementModal
    autocompleteFlash = null
    if (showElementModal) {
      const options = { metadata: getElementMetadata(listing, element), preventScrollTop: true }
      app.navigate(getElementPathname(listingId, elementId), options)
    } else {
      navigateToListingPathname()
    }
    e.preventDefault()
  }

  function navigateToListingPathname () {
    const options = { metadata: getListingMetadata(listing), preventScrollTop: true }
    app.navigate(getListingPathname(listingId), options)
  }

  async function onRemoveElement (e) {
    const element = e.detail
    await askUserConfirmationAndRemove(_removeElement, element?.comment)
      .catch(err => flash = err)
  }

  $: index = elements.findIndex(obj => obj.uri === uri)
  async function _removeElement () {
    return removeElement(listingId, uri)
      .then(() => {
        navigateToListingPathname()
        // Enhancement: after remove, have an "undo" button
        elements.splice(index, 1)
        elements = elements
      })
  }

  $: comment = element.comment
</script>
{#if showElementModal}
  <Modal on:closeModal={toggleShowMode}>
    <ListingElementShow
      {entity}
      {creator}
      bind:element
      on:removeElement={onRemoveElement}
      {isCreatorMainUser}
    />
  </Modal>
{/if}

<div class="listing-element-wrapper">
  <div class="listing-element">
    <a
      href="/lists/{listingId}/element/{element._id}"
      title={label}
      on:click={toggleShowMode}
    >
      {#if imageUrl}
        <ImageDiv
          url={imageUrl}
          size={100}
        />
      {/if}
      <div class="main-text-wrapper">
        <div>
          <span class="label">{label}</span>
          {#if publicationYear}
            <p
              class="publicationYear"
              title={i18n('wdt:P577')}
            >
              {publicationYear}
            </p>
          {/if}
          <AuthorsInline entitiesUris={authorsUris} />
        </div>
        {#if comment}
          <p class="comment">
            {@html userContent(comment.slice(0, 150))}
            {#if comment.length > 150}…{/if}
          </p>
        {/if}
      </div>
    </a>
    {#if isEditable}
      <ListingElementActions
        {element}
        bind:flash
        bind:elements
        {index}
      />
    {/if}
  </div>
  <Flash bind:state={flash} />
</div>
<style lang="scss">
  @import "#general/scss/utils";
  .listing-element-wrapper{
    @include display-flex(column, stretch, flex-start);
    width: 100%;
    padding: 1em;
  }
  .listing-element{
    @include display-flex(row, unset, space-between);
    min-height: 6em;
    a{
      @include display-flex(row, center, flex-start);
      cursor: pointer;
      flex: 1;
      :global(.image-div){
        block-size: 6em;
        flex: 0 0 4em;
        margin-inline-end: 1em;
      }
    }
  }
  .main-text-wrapper{
    @include display-flex(column, flex-start);
  }
  .comment{
    background-color: $off-white;
    padding: 0.5em 1em;
    @include radius;
  }
  .label{
    @include serif;
    padding-inline-end: 0.5em;
    font-size: 1.1em
  }
</style>
