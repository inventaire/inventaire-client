<script>
  import EntityPreview from './entity_preview.svelte'
  import { I18n } from 'modules/user/lib/i18n'
  import { imgSrc } from 'lib/handlebars_helpers/images'
  import { getAggregatedLabelsAndAliases } from './lib/deduplicate_helpers'
  import { createEventDispatcher } from 'svelte'

  export let entity, from, to, filterPattern

  const dispatch = createEventDispatcher()

  entity.image.small = imgSrc(entity.image.url, 100, 200)
  entity.image.large = imgSrc(entity.image.url, 500, 1000)
  let zoom = false
  const aggregatedLabelsAndAliases = getAggregatedLabelsAndAliases(entity)

  const isNotLast = (array, index) => array.length > index + 1
</script>

<button
  on:click={() => dispatch('select', entity)}
  class:selected-from={from?.uri === entity.uri}
  class:selected-to={to?.uri === entity.uri}
  >
  {#if entity.image.url}
    <img
      class:zoom
      src="{zoom ? entity.image.large : entity.image.small}"
      alt="{entity.label} cover"
      on:click|stopPropagation={() => zoom = !zoom}
    >
  {:else}
    <div class="no-image"></div>
  {/if}
  <div class="info">
    <h3><a class="label showEntity" href="/entity/{entity.uri}">{entity.label}</a></h3>
    <p class="description">{entity.description || ''}</p>
    <p class="uri" on:click|stopPropagation>{entity.uri}</p>
    <ul class="all-terms" on:click|stopPropagation>
      {#each aggregatedLabelsAndAliases as termData (termData.term)}
        {#if filterPattern}
          {#if termData.term.match(filterPattern)}
            <li>
              {#each termData.getMatchParts(filterPattern) as part, i}
                <!-- Odd parts are parts matching the filter and should be highlighted -->
                {#if i % 2 === 1}
                  <strong>{part}</strong>
                {:else}
                  {part}
                {/if}
              {/each}
              <span class="occurrences">({termData.origins.join(', ')})</span>
            </li>
          {/if}
        {:else}
          <li>
            {termData.term}
            <span class="occurrences">({termData.origins.join(', ')})</span>
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
  </div>
</button>

<style lang="scss">
  @import 'app/modules/general/scss/utils';

  button{
    background-color: white;
    @include radius;
    width: 100%;
    padding: 0.5em;
    transition: background-color 0.2s ease;
    display: flex;
    flex-direction: row;
    align-items: flex-start;
    justify-content: center;
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
  .uri, .all-terms{
    cursor: text;
    user-select: text;
  }
  .all-terms{
    font-weight: normal;
    text-align: left;
    max-height: 10em;
    overflow-y: auto;
  }
  .all-terms li{
    background-color: $off-white;
    padding: 0.1em;
    margin: 0.2em 0;
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
  .no-image, img{
    margin-right: 0.8em;
  }
  img{
    position: sticky;
    top: 64px;
  }
  .no-image, img:not(.zoom){
    width: 6em;
  }
  .info{
    flex: 1 0 0;
    text-align: left;
  }
  /*Large screens*/
  @media screen and (min-width: 1400px) {
    ul:not(:empty){
      flex-direction: row;
    }
  }
</style>
