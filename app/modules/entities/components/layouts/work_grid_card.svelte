<script>
  import { loadInternalLink } from '#lib/utils'
  import { getContext } from 'svelte'
  import ImagesCollage from '#components/images_collage.svelte'

  export let work

  const layoutContext = getContext('layout-context')

  const { type } = work
</script>

<a
  href={work.pathname}
  on:click={loadInternalLink}
  title={work.title}
  class="work-grid-card"
  class:serie={type === 'serie'}
  class:has-cover={work.images.length > 0}
  >
  <ImagesCollage
    imagesUrls={work.images}
    limit={type === 'serie' ? 6 : 1}
  />
  <div class="info">
    <h3>
      {#if layoutContext === 'serie' && work.serieOrdinal}
        {work.serieOrdinal}.
      {/if}
      {work.title}
    </h3>
    {#if work.subtitle}<p class="subtitle">{work.subtitle}</p>{/if}
  </div>
</a>

<style lang="scss">
  @import '#general/scss/utils';
  $card-base-width: 9em;
  $card-margin: 0.5em;
  .work-grid-card{
    @include display-flex(column, center, flex-end);
    background-color: $off-white;
    width: $card-base-width;
    height: 12em;
    margin: $card-margin;
    &.serie{
      width: calc($card-base-width * 2 + $card-margin * 2)
    }
    &:hover{
      @include shadow-box;
    }
    &.has-cover{
      position: relative;
      .info{
        @include display-flex(column, stretch, center);
        // Set a position so that the positionned image collage still appears below
        // Cf https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Positioning/Understanding_z_index/Adding_z-index
        position: relative;
        height: 4rem;
      }
      :global(.images-collage){
        @include position(absolute, 0, 0, 0, 0);
      }
    }
    &:not(.has-cover){
      background-color: $soft-grey;
      .info{
        @include display-flex(column, stretch, center);
        flex: 1;
      }
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
    max-height: calc(3 * $line-height + 0.2rem);
    overflow: hidden;
    font-size: 1rem;
    text-align: center;
    margin: 0;
  }
  .subtitle{
    line-height: 1rem;
    font-size: 0.8rem;
    text-align: center;
    color: $label-grey;
  }
</style>
