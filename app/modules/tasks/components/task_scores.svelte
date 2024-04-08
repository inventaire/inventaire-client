<script lang="ts">
  import Link from '#lib/components/link.svelte'
  import { calculateGlobalScore } from '#tasks/components/lib/tasks_helpers'
  import { i18n } from '#user/lib/i18n'

  export let task

  function buildMatchedTitlesString (matchedTitles) {
    return 'Matched titles: ' + matchedTitles.join(', ')
  }

  $: ({ externalSourcesOccurrences, lexicalScore } = task)
  $: sourcesCount = externalSourcesOccurrences?.length
  $: globalScore = calculateGlobalScore(task)
</script>
{#if globalScore}
  <li>
    <strong>{i18n('global match score')}:</strong>
    {globalScore}
  </li>
{/if}
<li>
  <strong>{i18n('sources')}:</strong>
  <span class="sources-count count-{sourcesCount}">{sourcesCount}</span>
  <ul class="sources-links">
    {#each externalSourcesOccurrences as source}
      {#if source.url}
        <li>
          <Link
            url={source.url}
            title={buildMatchedTitlesString(source.matchedTitles)}
            text={source.url}
          />
        </li>
      {/if}
      {#if source.uri}
        <li>
          <Link
            url={`/entity/${source.uri}`}
            title={buildMatchedTitlesString(source.matchedTitles)}
            text={source.matchedTitles}
          />
          <span class="uri">
            ({source.uri})
          </span>
        </li>
      {/if}
    {/each}
  </ul>
</li>
{#if lexicalScore}
  <li>
    <strong>{i18n('lexical score')}:</strong> {lexicalScore}
  </li>
{/if}

<style lang="scss">
  .sources-links{
    max-height: 7em;
    overflow-y: auto;
    padding-inline-start: 1em;
    :global(a:hover){
      text-decoration: underline;
    }
  }
</style>
