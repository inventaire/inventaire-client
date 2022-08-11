<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { loadInternalLink } from '#lib/utils'
  import { getContext } from 'svelte'

  export let work, displayMode

  const layoutContext = getContext('layout-context', 'serie')
</script>

{#if displayMode === 'grid'}
  <a
    href={work.pathname}
    on:click={loadInternalLink}
    title={work.label}
    class="work grid"
    class:has-cover={work.image.url != null}
    style:background-image={`url(${imgSrc(work.image.url, 200)})`}
    >
    <div class="info">
      <h3>
        {#if layoutContext === 'serie' && work.serieOrdinal}
          {work.serieOrdinal}.
        {/if}
        {work.label}
      </h3>
    </div>
  </a>
{:else}
  <div class="work list">
    <div class="cover">
      {#if work.image?.url}
        <img src={imgSrc(work.image.url, 200)} alt="{work.label}">
      {/if}
    </div>
    <div class="info">
      <h3>
        <a href={work.pathname} on:click={loadInternalLink} class="link" title={work.label}>
          {#if layoutContext === 'serie' && work.serieOrdinal}
            {work.serieOrdinal}.
          {/if}
          {work.label}
        </a>
      </h3>
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
    .info{
      margin: 0 1em;
      flex: 1;
    }
  }
  .grid{
    width: 9em;
    height: 12em;
    background-color: $soft-grey;
    background-size: cover;
    background-position: center center;
    margin: 0.5em;
    &:hover{
      @include shadow-box;
    }
    @include display-flex(column, center, flex-end);
    .info{
      align-self: stretch;
      @include display-flex(row, center);
      background-color: rgba($light-grey, 0.8);
      overflow: hidden;
    }
    &.has-cover{
      .info{
        height: 2.5rem;
      }
    }
    &:not(.has-cover){
      .info{
        flex: 1;
      }
    }
    h3{
      flex: 1;
      padding: 0.2em;
      line-height: 1.1rem;
      font-size: 1rem;
      margin: 0;
    }
  }
  h3{
    text-align: center;
  }
</style>
