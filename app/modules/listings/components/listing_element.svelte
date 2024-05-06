<script lang="ts">
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import { loadInternalLink } from '#app/lib/utils'
  import ImagesCollage from '#components/images_collage.svelte'
  import { getEntityImagePath } from '#entities/lib/entities'

  export let entity

  const { uri, label, description, image } = entity
  let imageUrl

  if (isNonEmptyArray(image)) {
    // This is the case when the entity object is a search result object
    imageUrl = getEntityImagePath(image[0])
  } else if (image?.url) {
    imageUrl = image.url
  }
</script>

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

<style lang="scss">
  @import "#general/scss/utils";
  a{
    @include display-flex(row, stretch, flex-start);
    height: 6em;
    flex: 1;
    padding: 0.5em;
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
