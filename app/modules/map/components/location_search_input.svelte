<script>
  import Spinner from '#components/spinner.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { fitResultBbox, searchLocationByText } from '#map/lib/nominatim'
  import { i18n } from '#user/lib/i18n'
  import { debounce } from 'underscore'

  export let map

  let results, flash
  let lastSearchQuery = ''

  let searching
  async function searchLocation (e) {
    const searchQuery = e.target.value
    if (searchQuery === lastSearchQuery && results != null) return
    lastSearchQuery = searchQuery
    if (searchQuery === '') {
      results = null
      return
    }
    try {
      searching = searchLocationByText(searchQuery)
      results = await searching
    } catch (err) {
      flash = err
    }
  }

  const lazySearchLocation = debounce(searchLocation, 500)

  function selectResult (result) {
    fitResultBbox(map, result)
    results = null
  }
</script>

<div class="location-search-input">
  <input
    type="search"
    on:focus={lazySearchLocation}
    on:keydown={lazySearchLocation}
    placeholder={i18n('Search for a location')}
  />
  {#await searching}
    <div class="spinner-wrapper">
      <Spinner />
    </div>
  {:then}
    {#if results}
      <ul tabindex="-1">
        {#each results as result (result.osm_id)}
          <li>
            <button on:click={() => selectResult(result)}>
              <span class="name">{result.name}</span>
              <span class="description">{result.description}</span>
            </button>
          </li>
        {:else}
          <li class="no-result">{i18n('no result')}</li>
        {/each}
      </ul>
    {/if}
  {/await}
  <Flash state={flash} />
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .location-search-input{
    position: absolute;
    inset-block-start: 0.5em;
    inset-inline-end: 0.5em;
    z-index: 1000;
    width: min(20em, 80%);
    @include radius;
    overflow: hidden;
  }
  input{
    margin: 0;
  }
  ul{
    background-color: $off-white;
    max-height: 20em;
    overflow-y: auto;
  }
  li{
    button{
      width: 100%;
      padding: 0.5em;
      text-align: start;
      @include bg-hover($off-white);
      span{
        display: block;
        line-height: 1.4rem;
      }
    }
  }
  .description, .no-result{
    color: $grey;
  }
  .no-result{
    text-align: center;
    padding: 0.5em;
  }
  li:not(:last-child){
    border-block-end: 1px solid $grey;
  }
  .spinner-wrapper{
    position: absolute;
    inset-block-start: 0.5em;
    inset-inline-end: 0.5em;
  }
</style>
