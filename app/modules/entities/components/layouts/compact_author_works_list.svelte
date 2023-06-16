<script>
  import Spinner from '#components/spinner.svelte'
  import EntityPreview from '#entities/components/entity_preview.svelte'
  import { getAuthorExtendedWorks } from '#entities/lib/types/author_alt'
  import { I18n } from '#user/lib/i18n'

  export let author

  let articles, series, works

  const waitForData = getAuthorExtendedWorks({
    uri: author.uri,
    attributes: [ 'type', 'labels', 'descriptions', 'image' ]
  })
    .then(res => ({ articles, series, works } = res))

</script>

<div class="compact-author-works-list">
  {#await waitForData}
    <Spinner />
  {:then}
    {#if series?.length > 0}
      <h4>{I18n('series')}</h4>
      <ul>
        {#each series as serie}
          <li><EntityPreview entity={serie} /></li>
        {/each}
      </ul>
    {/if}

    {#if works?.length > 0}
      <h4>{I18n('works')}</h4>
      <ul>
        {#each works as work}
          <li><EntityPreview entity={work} /></li>
        {/each}
      </ul>
    {/if}

    {#if articles?.length > 0}
      <h4>{I18n('articles')}</h4>
      <ul>
        {#each articles as article}
          <li><EntityPreview entity={article} /></li>
        {/each}
      </ul>
    {/if}
  {/await}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .compact-author-works-list{
    align-self: stretch;
    background-color: $light-grey;
    max-height: 10em;
    overflow-y: auto;
    padding: 0.5em;
    @include radius;
    &:not(:empty){
      margin: 0.5em 0;
    }
  }
  h4{
    font-size: 1rem;
    text-align: center;
    @include sans-serif;
  }
</style>
