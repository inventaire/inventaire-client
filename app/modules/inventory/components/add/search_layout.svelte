<script lang="ts">
  import { icon } from '#app/lib/icons'
  import { commands } from '#app/radio'
  import { clearSearchHistory, searchResultsHistory } from '#search/lib/search_results_history'
  import { I18n } from '#user/lib/i18n'
  import PreviousSearch from './previous_search.svelte'

  function onClick (e) {
    const type = e.currentTarget.href.split('type=')[1]
    commands.execute('search:global', '', type)
    e.preventDefault()
  }
</script>

<div class="add-search-layout">
  <section class="inner">
    <h3>{I18n('search by')}</h3>
    <div class="search-buttons">
      <a href="/search?type=work" class="search-button" on:click={onClick}>
        {@html icon('search')}
        {I18n('work')}
      </a>
      <a href="/search?type=author" class="search-button" on:click={onClick}>
        {@html icon('search')}
        {I18n('author')}
      </a>
      <a href="/search?type=serie" class="search-button" on:click={onClick}>
        {@html icon('search')}
        {I18n('series_singular')}
      </a>
      <a href="/search?type=subject" class="search-button" on:click={onClick}>
        {@html icon('search')}
        {I18n('subject')}
      </a>
    </div>
  </section>
</div>

{#if $searchResultsHistory.length > 0}
  <div class="history-wrapper">
    <h3>{@html icon('history')}{I18n('previous searches')}</h3>
    <ul class="history">
      {#each $searchResultsHistory as entry}
        <PreviousSearch {entry} />
      {/each}
    </ul>
    <button class="clear-history" on:click={clearSearchHistory}>{@html icon('trash')}{I18n('clear history')}</button>
  </div>
{/if}

<style lang="scss">
  @import '#general/scss/utils';

  .add-search-layout{
    text-align: center;
    section{
      padding-block-start: 1em;
    }
  }
  .search-buttons{
    @include display-flex(row, center, center, wrap);
  }
  .search-button{
    @include tiny-button($grey);
    @include tiny-button-color($light-blue, null, 5%);
    margin: 1em;
  }
  .history-wrapper{
    margin-block-start: 2em;
    @include display-flex(column, stretch);
  }
  .history{
    width: min(30em, 95vw);
    margin: 0;
    align-self: center;
    @include display-flex(column, stretch);
  }
  .clear-history{
    @include shy(0.7);
  }
</style>
