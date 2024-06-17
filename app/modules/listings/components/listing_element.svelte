<script lang="ts">
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { loadInternalLink } from '#app/lib/utils'
  import ImagesCollage from '#components/images_collage.svelte'
  import { getEntityImagePath } from '#entities/lib/entities'
  import ListingElementActions from './listing_element_actions.svelte'

  export let isEditable, isReordering, element, elements, paginatedElements, listingId

  const { entity } = element
  const { uri, label, description, image } = entity
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
        <!-- The type isn't useful as long as lists only contain works -->
        <!-- <span class="type">{type}</span> -->
        {#if description}
          <div class="description">{description}</div>
        {/if}
      </div>
    </a>
    {#if isEditable}
      <ListingElementActions
        bind:isReordering
        {element}
        {elements}
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
    padding-inline-end: 0.5em;
  }
  .description{
    color: $label-grey;
    margin-inline-end: 1em;
  }
</style>
