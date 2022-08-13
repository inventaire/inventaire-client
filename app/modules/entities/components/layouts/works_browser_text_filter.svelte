<script>
  import Spinner from '#components/spinner.svelte'
  import assert_ from '#lib/assert_types'
  import { icon } from '#lib/handlebars_helpers/icons'
  import preq from '#lib/preq'
  import { onChange } from '#lib/svelte'
  import { i18n } from '#user/lib/i18n'
  import { getContext } from 'svelte'
  import { debounce, pluck } from 'underscore'

  export let textFilterUris

  let searchFilterClaim = getContext('search-filter-claim')
  assert_.string(searchFilterClaim)

  let textFilter, waiting

  async function search () {
    if (!textFilter) {
      textFilterUris = null
      return
    }
    waiting = preq.get(app.API.search({
      types: [ 'works', 'series' ],
      claim: searchFilterClaim,
      search: textFilter,
      limit: 100,
    }))
    const { results } = await waiting
    textFilterUris = pluck(results, 'uri')
  }

  const lazySearch = debounce(search, 200)

  $: onChange(textFilter, lazySearch)
</script>

<div class="wrapper">
  <input type="text" placeholder={i18n('Filter...')} bind:value={textFilter}>
  <div class="search-icon">
    {#await waiting}
      <Spinner />
    {:then}
      {@html icon('search')}
    {/await}
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .wrapper{
    align-self: flex-end;
    position: relative;
  }
  .search-icon{
    position: absolute;
    right: 0.5em;
    top: 0.5em;
    color: $grey;
  }
  input{
    margin: 0;
    @include radius(2em);
  }
</style>
