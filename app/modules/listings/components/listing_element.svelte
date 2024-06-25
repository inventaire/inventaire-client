<script lang="ts">
  import { isNonEmptyPlainObject, isNonEmptyArray } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { userContent } from '#app/lib/handlebars_helpers/user_content'
  import ImageDiv from '#components/image_div.svelte'
  import Modal from '#components/modal.svelte'
  import EntityImage from '#entities/components/entity_image.svelte'
  import AuthorsInfo from '#entities/components/layouts/authors_info.svelte'
  import AuthorsInline from '#entities/components/layouts/authors_inline.svelte'
  import Ebooks from '#entities/components/layouts/ebooks.svelte'
  import EntityTitle from '#entities/components/layouts/entity_title.svelte'
  import Infobox from '#entities/components/layouts/infobox.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import { formatYearClaim } from '#entities/components/lib/claims_helpers'
  import { getEntityImagePath } from '#entities/lib/entities'
  import { i18n, I18n } from '#user/lib/i18n'
  import ListingElementActions from './listing_element_actions.svelte'

  export let isEditable, isReordering, element, elements, listingId

  let isShowMode
  const { entity } = element
  const { uri, type, label, claims, image } = entity
  const publicationYear = formatYearClaim('wdt:P577', claims)
  const authorsUris = claims['wdt:P50']

  let imageUrl, flash

  if (isNonEmptyArray(image)) {
    // This is the case when the entity object is a search result object
    imageUrl = getEntityImagePath(image[0])
  } else if (image?.url) {
    imageUrl = image.url
  }

  function toggleShowMode () {
    isShowMode = !isShowMode
  }

  $: comment = element.comment
</script>

{#if isShowMode}
  <Modal on:closeModal={() => isShowMode = false}
  >
    <div class="show-modal">
      <div class="entity-type-label">
        {I18n(type)}
      </div>
      <EntityTitle
        {entity}
        hasLinkTitle={true}
      />
      <div class="entity-info-row">
        {#if isNonEmptyPlainObject(entity.image)}
          <EntityImage
            {entity}
            size={128}
          />
        {/if}
        <div class="entity-infobox">
          <AuthorsInfo {claims} />
          <Infobox
            {claims}
            entityType={type}
            shortlistOnly={true}
          />
          <Ebooks {entity} />
        </div>
      </div>
      {#if comment}
        <div class="element-section">
          <div class="entity-label">
            {I18n("creator's comment")}
          </div>
          <p>{@html userContent(comment)}</p>
        </div>
      {/if}
      <Summary {entity} />
    </div>
  </Modal>
{/if}

<div class="listing-element-wrapper">
  <div class="listing-element">
    <a
      href="/entity/{uri}"
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
          <p>{@html userContent(comment.slice(0, 150))}</p>
        {/if}
      </div>
    </a>
    {#if isEditable}
      <ListingElementActions
        bind:isReordering
        {element}
        {listingId}
        bind:flash
        bind:elements
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
    padding: 0.5em;
  }
  .listing-element{
    @include display-flex(row, unset, space-between);
    min-height: 6em;
  }
  a{
    @include display-flex(row, stretch, flex-start);
    cursor: pointer;
    flex: 1;
    :global(.image-div){
      block-size: 6em;
      flex: 0 0 4em;
      margin-inline-end: 0.5em;
    }
  }
  .main-text-wrapper{
    @include display-flex(column, flex-start);
  }
  .label{
    @include serif;
    padding-inline-end: 0.5em;
    font-size: 1.1em
  }
  .publication-year{
    color: $label-grey;
    font-size: 0.9rem;
  }
  .show-modal{
    margin: 1em;
  }
  .entity-info-row{
    @include display-flex(row, flex-start, flex-start);
    margin: 1em 0;
  }
  .entity-infobox{
    margin: 0 1em;
  }
  .element-section{
    background-color: $light-grey;
    padding: 0.5em 1em;
    margin: 1em 0;
  }
  .entity-type-label{
    color: $soft-grey;
    text-align: center;
  }
  .entity-label{
    color: $soft-grey;
  }
</style>
