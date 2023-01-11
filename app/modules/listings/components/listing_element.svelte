<script>
  import { loadInternalLink } from '#lib/utils'
  import { i18n } from '#user/lib/i18n'
  import { createEventDispatcher } from 'svelte'
  import ImagesCollage from '#components/images_collage.svelte'
  import { getEntityImagePath } from '#entities/lib/entities'
  import { isNonEmptyArray } from '#lib/boolean_tests'

  export let entity, isEditable

  const dispatch = createEventDispatcher()

  const { uri, label, description, image } = entity
  let imageUrl

  if (isNonEmptyArray(image)) {
    // This is the case when the entity object is a search result object
    imageUrl = getEntityImagePath(image[0])
  } else if (image?.url) {
    imageUrl = image.url
  }
</script>

<li>
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
    <div class="status">
      <button
        class="tiny-button"
        on:click={() => dispatch('removeElement')}
      >
        {i18n('remove')}
      </button>
    </div>
  {/if}
</li>

<style lang="scss">
  @import "#general/scss/utils";
  li{
    @include display-flex(row, center);
    padding-right: 0.5em;
    width: 100%;
    border-bottom: 1px solid $light-grey;
    @include bg-hover(white);
  }
  a{
    @include display-flex(row, stretch, flex-start);
    height: 6em;
    flex: 1;
    padding: 0.5em;
    :global(.images-collage){
      flex: 0 0 4em;
      margin-right: 0.5em;
    }
  }
  .label{
    padding-right: 0.5em;
  }
  .description{
    color: $label-grey;
    margin-right: 1em;
  }
  .status{
    @include display-flex(row, center, center);
    white-space: nowrap;
  }
  /* Very small screens */
  @media screen and (max-width: $below-very-small-screen){
    li{
      @include display-flex(column, flex-start);
    }
  }
</style>
