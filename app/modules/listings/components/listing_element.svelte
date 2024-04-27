<script lang="ts">
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { userContent } from '#app/lib/handlebars_helpers/user_content'
  import { loadInternalLink } from '#app/lib/utils'
  import ImageDiv from '#components/image_div.svelte'
  import AuthorsInline from '#entities/components/layouts/authors_inline.svelte'
  import { formatYearClaim } from '#entities/components/lib/claims_helpers'
  import { getEntityImagePath } from '#entities/lib/entities'
  import { i18n } from '#user/lib/i18n'
  import ListingElementActions from './listing_element_actions.svelte'

  export let isEditable, isReordering, element, elements, listingId

  const { entity } = element
  const { uri, label, claims, image } = entity
  const publicationYear = formatYearClaim('wdt:P577', claims)
  const authorsUris = claims['wdt:P50']

  let imageUrl, flash

  if (isNonEmptyArray(image)) {
    // This is the case when the entity object is a search result object
    imageUrl = getEntityImagePath(image[0])
  } else if (image?.url) {
    imageUrl = image.url
  }

  $: comment = element.comment
</script>

<div class="listing-element-section">
  <div class="listing-element">
    <a
      href="/entity/{uri}"
      title={label}
      on:click={loadInternalLink}
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
          <p>{@html userContent(comment)}</p>
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
  .listing-element-section{
    @include display-flex(column, stretch, flex-start);
    width: 100%;
    padding: 0.5em;
  }
  .listing-element{
    @include display-flex(row, unset, space-between);
    min-height: 6em;
    flex: 1;
  }
  a{
    @include display-flex(row, stretch, flex-start);
    :global(.image-div){
      // block-size: 6em;
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
  .actions{
    @include display-flex(column, flex-end);
    @include shy-button-label;
  }
  button{
    margin-block-end: 0.5em;
  }
</style>
