<script lang="ts">
  import { imgSrc } from '#app/lib/image_source'
  import { loadInternalLink } from '#app/lib/utils'
  import { getEntityPathname } from '#entities/lib/entities'
  import type { HistoryEntry } from '#search/lib/search_results_history'

  export let entry: HistoryEntry

  const { uri, label, pictures } = entry
  const pathname = getEntityPathname(uri)
</script>

<li class="previous-search">
  <a href={pathname} on:click={loadInternalLink}>
    <div class="pics">
      {#each pictures as picture}
        <img src={imgSrc(picture, 96)} alt="" loading="lazy" />
      {/each}
    </div>
    <div class="info">
      <p class="label">{label}</p>
      <p class="uri">{uri}</p>
    </div>
  </a>
</li>

<style lang="scss">
  @use '#general/scss/utils';
  $base: 6em;

  .previous-search{
    align-self: stretch;
    :global(.fa){
      opacity: 0.5;
    }
  }
  a{
    @include display-flex(row, center);
    @include panel;
    @include bg-hover(white, 4%);
  }
  .info{
    margin: 0 auto;
    flex: 1 1 auto;
    padding-inline-end: 0.5em;
    font-size: 1.1em;
    text-align: center;
  }
  .pics{
    max-height: $base;
    max-width: $base * 3;
    overflow: hidden;
  }
  /* Very small screens */
  @media screen and (width < $very-small-screen){
    a{
      flex-flow: column-reverse;
    }
    img{
      max-height: 5em;
    }
    .pics{
      padding-block-start: 1em;
    }
  }
</style>
