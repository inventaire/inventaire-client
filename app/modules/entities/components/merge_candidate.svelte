<script>
  import EntityPreview from './entity_preview.svelte'
  import { I18n } from 'modules/user/lib/i18n'
  import { imgSrc } from 'lib/handlebars_helpers/images'
  import { getAggregatedLabelsAndAliases } from './lib/deduplicate_helpers'
  export let entity, selection, filterPattern, large

  entity.image.small = imgSrc(entity.image.url, 200, 400)
  entity.image.large = imgSrc(entity.image.url, 500, 1000)
  let zoom = false
  const aggregatedLabelsAndAliases = getAggregatedLabelsAndAliases(entity)

  const isNotLast = (array, index) => array.length > index + 1
</script>

<button
  on:click={() => selection.select(entity)}
  class:selected-from={$selection.from?.uri === entity.uri}
  class:selected-to={$selection.to?.uri === entity.uri}
  class:zoom
  class:large
  >
  {#if entity.image.url}
    <img
      src="{zoom ? entity.image.large : entity.image.small}"
      alt="{entity.label} cover"
      on:click|stopPropagation={() => zoom = !zoom}
    >
  {/if}
  <h3><a class="label showEntity" href="/entity/{entity.uri}">{entity.label}</a></h3>
  <p class="description">{entity.description || ''}</p>
  <p class="uri">{entity.uri}</p>
  <ul class="all-terms">
    {#each aggregatedLabelsAndAliases as termData (termData.term)}
      {#if filterPattern}
        {#if termData.term.match(filterPattern)}
          <li title="{termData.origins.join(', ')}">
            {#each termData.getMatchParts(filterPattern) as part, i}
              <!-- Odd parts are parts matching the filter and should be highlighted -->
              {#if i % 2 === 1}
                <strong>{part}</strong>
              {:else}
                {part}
              {/if}
            {/each}
            {#if termData.origins.length > 1}
              <span class="occurrences">({termData.origins.length})</span>
            {/if}
          </li>
        {/if}
      {:else}
        <li title="{termData.origins.join(', ')}">
          {termData.term}
          {#if termData.origins.length > 1}
            <span class="occurrences">({termData.origins.length})</span>
          {/if}
        </li>
      {/if}
    {/each}
  </ul>
  {#if entity.series?.length > 0}
    <ul class="series">
      <h4>
        {I18n('series')}
        <span class="count">{entity.series.length}</span>
      </h4>
      <ul>
        {#each entity.series as serie (serie.uri)}
          <li class="entity-preview"><EntityPreview entity={serie} /></li>
        {/each}
      </ul>
    </ul>
  {/if}
  {#if entity.works?.length > 0}
    <ul class="works">
      <h4>
        {I18n('works')}
        <span class="count">{entity.works.length}</span>
      </h4>
      <ul>
        {#each entity.works as work (work.uri)}
          <li class="entity-preview"><EntityPreview entity={work} /></li>
        {/each}
      </ul>
    </ul>
  {/if}
  {#if entity.coauthors?.length > 0}
    <p class="coauthors">
      {I18n('coauthors')}:
      {#each entity.coauthors as author, i (author.uri)}
        <a href="{author.pathname}" title="{author.label}">{author.label}</a>{#if isNotLast(entity.coauthors, i)},&nbsp;{/if}
      {/each}
    </p>
  {/if}
</button>

<style lang="scss">
  @import 'app/modules/general/scss/utils';

  button{
    background-color: white;
    @include radius;
    width: 100%;
    padding: 0.5em;
    transition: background-color 0.2s ease;
  }
  button:not(.zoom):not(.large){
    max-width: 15em;
  }
  button.zoom{
    max-width: 31em;
  }
  button.zoom img{
    cursor: zoom-out;
  }
  button:not(.zoom) img{
    cursor: zoom-in;
  }

  .large{
    max-width: 25em;
  }

  button:hover{
    opacity: 0.95;
  }
  .selected-from, .selected-to{
    a, .uri, .coauthors{
      color: white !important;
    }
  }
  .selected-from{
    background-color: $soft-red;
  }
  .selected-to{
    background-color: $green-tree;
  }
  h3{
    font-size: 1.2em;
  }
  h4{
    font-size: 1.1em;
  }
  .label, .description, h3, h4{
    margin: 0;
  }
  .description{
    color: $grey;
  }
  .entity-preview{
    background-color: $light-grey;
    padding: 0.5em;
    margin: 0.5em 0;
    @include radius;
  }
  .showEntity{
    font-weight: normal;
    font-size: 1.1em;
    font-family: $serif;
  }
  .showEntity:hover{
    text-decoration: underline;
  }
  .count{
    background-color: $off-white;
    @include radius;
    text-align: center;
    padding: 0 0.3em;
    font-size: 1rem;
    margin: 0 0.5em;
  }
  .all-terms{
    font-weight: normal;
    text-align: left;
    max-height: 10em;
    overflow-y: auto;
    // background-color: $grey;
  }
  .all-terms li{
    background-color: $off-white;
    padding: 0.1em;
    margin: 0.2em;
  }
  .occurrences{
    color: $grey;
  }
  .coauthors a:hover{
    text-decoration: underline;
  }
  .works, .series{
    ul{
      max-height: 10em;
      overflow-y: auto;
    }
  }
</style>
