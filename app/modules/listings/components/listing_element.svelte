<script lang="ts">
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { loadInternalLink } from '#app/lib/utils'
  import ImagesCollage from '#components/images_collage.svelte'
  import AuthorsInline from '#entities/components/layouts/authors_inline.svelte'
  import { formatYearClaim } from '#entities/components/lib/claims_helpers'
  import { getEntityImagePath } from '#entities/lib/entities'
  import { i18n } from '#user/lib/i18n'
  import ListingElementActions from './listing_element_actions.svelte'

  export let isEditable, isReordering, element, paginatedElements, listingId

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
</script>
<div class="listing-element-section">
  <div class="listing-element">
    <a
      href="/entity/{uri}"
      title={label}
      on:click={loadInternalLink}
    >
      {#if imageUrl}
        <ImagesCollage
          imagesUrls={[ imageUrl ]}
          imageSize={100}
          limit={1}
        />
      {/if}
      <div>
        <span class="label">{label}</span>
        {#if publicationYear}
          <p
            class="publication-year"
            title={i18n('wdt:P577')}
          >
            {publicationYear}
          </p>
        {/if}
        <AuthorsInline entitiesUris={authorsUris} />
      </div>
    </a>
    {#if isEditable}
      <ListingElementActions
        bind:isReordering
        {element}
        {listingId}
        bind:flash
        bind:paginatedElements
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
    @include display-flex(row, stretch, flex-start);
  }
  a{
    height: 6em;
    flex: 1;
    @include display-flex(row, stretch, flex-start);
    :global(.images-collage){
      flex: 0 0 4em;
      margin-inline-end: 0.5em;
    }
  }
  .label{
    @include serif;
    padding-inline-end: 0.3em;
  }
  .publication-year{
    color: $label-grey;
    font-size: 0.9rem;
  }
</style>
