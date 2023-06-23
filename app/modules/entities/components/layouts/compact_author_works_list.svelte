<script>
  import Spinner from '#components/spinner.svelte'
  import EntityPreview from '#entities/components/entity_preview.svelte'
  import { getAuthorExtendedWorks } from '#entities/lib/types/author_alt'
  import { I18n } from '#user/lib/i18n'

  export let author

  let series, works, articles, empty

  const waitForData = getAuthorExtendedWorks({
    uri: author.uri,
    attributes: [ 'type', 'labels', 'descriptions', 'claims', 'image' ]
  })
    .then(res => {
      ;({ series, works, articles } = res)
      empty = series.length === 0 && works.length === 0 && articles.length === 0
    })
</script>

<div class="compact-author-works-list" class:empty>
  {#await waitForData}
    <Spinner />
  {:then}
    {#if series?.length > 0}
      <div class="section">
        <h4>
          {I18n('series')}
          <span class="counter">{series.length}</span>
        </h4>
        <ul>
          {#each series as serie}
            <li><EntityPreview entity={serie} /></li>
          {/each}
        </ul>
      </div>
    {/if}

    {#if works?.length > 0}
      <div class="section">
        <h4>
          {I18n('works')}
          <span class="counter">{works.length}</span>
        </h4>
        <ul>
          {#each works as work}
            <li><EntityPreview entity={work} /></li>
          {/each}
        </ul>
      </div>
    {/if}

    {#if articles?.length > 0}
      <div class="section">
        <h4>
          {I18n('articles')}
          <span class="counter">{articles.length}</span>
        </h4>
        <ul>
          {#each articles as article}
            <li><EntityPreview entity={article} /></li>
          {/each}
        </ul>
      </div>
    {/if}
  {/await}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .compact-author-works-list{
    align-self: stretch;
    &.empty{
      display: none;
    }
  }
  .section{
    background-color: $light-grey;
    padding: 0.5em;
    margin: 0.5em 0;
    @include radius;
  }
  h4{
    font-size: 1rem;
    margin: 0.5em 0 0;
    text-align: center;
    @include sans-serif;
    &:first-child{
      margin-block-start: 0;
    }
  }
  .counter{
    color: $grey;
    font-size: 0.9rem;
    background-color: white;
    padding: 0 0.3em;
    margin-inline-start: 0.5em;
    @include radius;
  }
  ul{
    max-block-size: 10em;
    overflow-y: auto;
    li{
      margin: 0.1em 0;
    }
  }
</style>
