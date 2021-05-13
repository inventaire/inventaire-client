<script>
  import preq from 'lib/preq'
  import Spinner from 'modules/general/components/spinner.svelte'
  import { createEventDispatcher } from 'svelte'

  const waitingForNames = fetchNames()
  let names

  async function fetchNames () {
    const res = await preq.get(app.API.entities.duplicates)
    names = res.names
  }

  const dispatch = createEventDispatcher()
</script>

{#await waitingForNames}
  <p class="loading">Loading authors... <Spinner/></p>
{:then}
  <h2>Author names with most occurrences</h2>
  <ul class="names">
    {#each names as nameData (nameData.key)}
      <li>
        <button
          class="name tiny-button light-blue"
          on:click={() => dispatch('select', nameData.key)}
        >{nameData.key} ({nameData.value})</button>
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
  }
  .name{
    margin: 0.2em;
    padding: 0.3em;
    font-weight: normal;
  }
  h2{
    margin-top: 2.5em;
    text-align: center;
    font-size: 1.3em;
  }
</style>
