<script lang="ts">
  import { API } from '#app/api/api'
  import preq from '#app/lib/preq'
  import { loadInternalLink } from '#app/lib/utils'
  import Spinner from '#general/components/spinner.svelte'

  const waitingForNames = fetchNames()
  let names

  async function fetchNames () {
    const res = await preq.get(API.entities.duplicates)
    names = res.names
  }
</script>

{#await waitingForNames}
  <p class="loading">Loading authors... <Spinner /></p>
{:then}
  <h2>Author names with most occurrences</h2>
  <ul class="names">
    {#each names as nameData (nameData.key)}
      <li>
        <a
          href={`/search?q=!a ${encodeURIComponent(nameData.key)}`}
          on:click={loadInternalLink}
          class="name tiny-button light-blue">
          {nameData.key} ({nameData.value})
        </a>
      </li>
    {/each}
  </ul>
{:catch}
  <p>Oops! Failed to load data</p>
{/await}

<style>
  .loading, .names{
    text-align: center;
    display: flex;
    align-items: flex-start;
    justify-content: center;
  }
  .names{
    flex-wrap: wrap;
    padding: 1em;
  }
  .name{
    display: inline-block;
    margin: 0.2em;
    padding: 0.3em;
    font-weight: normal;
  }
  h2{
    margin-block-start: 2.5em;
    text-align: center;
    font-size: 1.3em;
  }
</style>
