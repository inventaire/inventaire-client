<script>
  import { loadInternalLink } from '#lib/utils'
  import { getContext } from 'svelte'
  import ImagesCollage from '#components/images_collage.svelte'
  import Infobox from '#entities/components/layouts/infobox.svelte'

  export let work

  const layoutContext = getContext('layout-context')
</script>

<div class="work-list-row">
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
    <Infobox
      claims={work.claims}
      entityType={work.type}
    />
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .work-list-row{
    @include display-flex(row, flex-start);
    background-color: white;
    margin: 0.5em 0;
    padding: 1em;
    @include radius;
    :global(.images-collage){
      width: 9em;
      height: 12em;
    }
  }
  .info{
    margin: 0 1em;
    flex: 1;
  }
  .subtitle{
    line-height: 1rem;
    font-size: 0.8rem;
    text-align: center;
    color: $label-grey;
  }
</style>
