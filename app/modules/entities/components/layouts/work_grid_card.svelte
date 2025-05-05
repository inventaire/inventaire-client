<script lang="ts">
  import { getContext } from 'svelte'
  import { loadInternalLink } from '#app/lib/utils'
  import ImagesCollage from '#components/images_collage.svelte'
  import { isSubEntitiesType } from '#entities/components/lib/works_browser_helpers'

  export let work

  const layoutContext = getContext('layout-context')

  const { type } = work
</script>

<a
  href={work.pathname}
  on:click={loadInternalLink}
  title={work.label}
  class="work-grid-card"
  class:hasSubEntities={isSubEntitiesType(type)}
>
  <ImagesCollage
    imagesUrls={work.images || []}
    limit={isSubEntitiesType(type) ? 6 : 1}
  />
  <div class="info">
    <h3>
      {#if layoutContext === 'serie' && work.serieOrdinal}
        {work.serieOrdinal}.
      {/if}
      {work.label}
    </h3>
  </div>
</a>

<style lang="scss">
  @import "#general/scss/utils";
  $card-base-width: 9em;
  $card-margin: 0.5em;
  .work-grid-card{
    @include display-flex(column, center, flex-end);
    background-color: $off-white;
    inline-size: $card-base-width;
    block-size: 12em;
    margin: $card-margin;
    &.hasSubEntities{
      inline-size: calc($card-base-width * 2 + $card-margin * 2);
    }
    &:hover{
      @include shadow-box;
    }
    position: relative;
    .info{
      @include display-flex(column, stretch, center);
      // Set a position so that the positionned image collage still appears below
      // Cf https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Positioning/Understanding_z_index/Adding_z-index
      position: relative;
      block-size: 4rem;
      text-wrap: balance;
    }
    :global(.images-collage){
      @include position(absolute, 0, 0, 0, 0);
    }
  }
  .info{
    align-self: stretch;
    background-color: rgba($light-grey, 0.8);
    overflow: hidden;
  }
  h3{
    padding: 0.2em;
    $line-height: 1.1rem;
    line-height: $line-height;
    max-block-size: calc(3 * $line-height + 0.2rem);
    overflow: hidden;
    font-size: 1rem;
    text-align: center;
    margin: 0;
  }
</style>
