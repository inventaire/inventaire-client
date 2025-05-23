<script lang="ts">
  import Link from '#app/lib/components/link.svelte'
  import { imgSrc } from '#app/lib/image_source'
  import { getActionKey } from '#app/lib/key_events'
  import { I18n } from '#user/lib/i18n'
  import EntityPreview from './entity_preview.svelte'

  export let entity
  export let filterPattern: RegExp = null
  export let aggregatedLabelsAndAliases = null

  entity.image.small = imgSrc(entity.image.url, 100, 200)
  entity.image.large = imgSrc(entity.image.url, 500, 1000)
  let zoom = false

  const isNotLast = (array, index) => array.length > index + 1

  function toggleZoomOnEnter (e) {
    const key = getActionKey(e)
    if (key === 'enter') zoom = !zoom
  }
</script>

{#if entity.image.url}
  <!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
  <img
    class:zoom
    src={zoom ? entity.image.large : entity.image.small}
    alt=""
    loading="lazy"
    on:click|stopPropagation={() => zoom = !zoom}
    on:keyup={toggleZoomOnEnter}
  />
{:else}
  <div class="no-image" />
{/if}
<div class="info">
  <h3>
    <Link url={`/entity/${entity.uri}`} text={entity.label} />
  </h3>
  <p class="description">{entity.description || ''}</p>
  <!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
  <p
    class="uri"
    on:click|stopPropagation
    on:keyup|stopPropagation
  >{entity.uri}</p>
  <!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
  {#if filterPattern && aggregatedLabelsAndAliases}
    <ul
      class="all-terms"
      on:click|stopPropagation
      on:keyup|stopPropagation
    >
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
  {/if}
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
        <a href={author.pathname} title={author.label}>{author.label}</a>{#if isNotLast(entity.coauthors, i)},&nbsp;{/if}
      {/each}
    </p>
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";

  h3{
    font-size: 1.2em;
    :global(a){
      font-weight: normal;
      font-size: 1.1em;
      font-family: $serif;
      user-select: text;
      &:hover{
        text-decoration: underline;
      }
    }
  }
  h4{
    font-size: 1.1em;
  }
  .description, h3, h4{
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
    text-align: start;
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
    margin-inline-end: 0.8em;
  }
  img{
    position: sticky;
    inset-block-start: 64px;
    cursor: zoom-in;
    &.zoom{
      cursor: zoom-out;
    }
  }
  .no-image, img:not(.zoom){
    width: 3em;
  }
  .info{
    flex: 1 0 0;
    text-align: start;
  }
  /* Large screens */
  @media screen and (width >= 1800px){
    ul:not(:empty){
      flex-direction: row;
    }
  }
</style>
