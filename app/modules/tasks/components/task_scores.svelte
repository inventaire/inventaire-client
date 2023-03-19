<script>
  import { i18n } from '#user/lib/i18n'
  import Link from '#lib/components/link.svelte'
  import { calculateGlobalScore } from '#tasks/lib/tasks_helper'

  export let task

  function buildMatchedTitlesString (matchedTitles) {
    return 'Matched titles: ' + matchedTitles.join(', ')
  }

  $: ({ externalSourcesOccurrences, lexicalScore } = task)
  $: sourcesCount = externalSourcesOccurrences?.length
  $: globalScore = calculateGlobalScore(task)
</script>
<li>
  <strong>{i18n('global match score')}:</strong>
  {globalScore}
</li>
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
          source.sourceTitle
          <span class="uri">
            ({source.uri})
          </span>
        </li>
      {/if}
    {/each}
  </ul>
</li>
<li><strong>{i18n('lexical score')}:</strong> {lexicalScore}</li>

<style lang="scss">
  .sources-links{
    :global(a:hover){
      text-decoration: underline;
    }
  }
</style>
