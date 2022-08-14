<script>
  import { loadInternalLink } from '#lib/utils'
  import { getContext } from 'svelte'
  import ImagesCollage from '#components/images_collage.svelte'

  export let work, displayMode

  const layoutContext = getContext('layout-context', 'serie')
</script>

{#if displayMode === 'grid'}
  <a
    href={work.pathname}
    on:click={loadInternalLink}
    title={work.title}
    class="work grid"
    class:has-cover={work.images.length > 0}
    >
    <ImagesCollage
      imagesUrls={work.images}
      limit={work.type === 'serie' ? 4 : 1}
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
{:else}
  <div class="work list">
    <div class="cover">
      <ImagesCollage
        imagesUrls={work.images}
        limit={work.type === 'serie' ? 4 : 1}
      />
    </div>
    <div class="info">
      <h3>
        <a href={work.pathname} on:click={loadInternalLink} class="link" title={work.title}>
          {#if layoutContext === 'serie' && work.serieOrdinal}
            {work.serieOrdinal}.
          {/if}
          {work.title}
        </a>
      </h3>
      {#if work.subtitle}<p class="subtitle">{work.subtitle}</p>{/if}
    </div>
  </div>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .work{
    background-color: $off-white;
  }
  .list{
    margin: 0.5em 0;
    padding: 1em;
    @include radius;
    @include display-flex(row, flex-start);
    :global(.images-collage){
      width: 9em;
      height: 12em;
    }
    .info{
      margin: 0 1em;
      flex: 1;
    }
  }
  .grid{
    width: 9em;
    height: 12em;
    margin: 0.5em;
    &:hover{
      @include shadow-box;
    }
    @include display-flex(column, center, flex-end);
    .info{
      align-self: stretch;
      background-color: rgba($light-grey, 0.8);
      overflow: hidden;
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
    h3{
      padding: 0.2em;
      line-height: 1.1rem;
      font-size: 1rem;
      margin: 0;
    }
  }
  h3{
    text-align: center;
  }
  .subtitle{
    line-height: 1rem;
    font-size: 0.8rem;
    text-align: center;
    color: $label-grey;
  }
</style>
