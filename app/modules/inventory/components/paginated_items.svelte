<script>
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import viewport from '#lib/components/actions/viewport'

  export let Component, componentProps, pagination

  const { fetchMore, hasMore, allowMore } = pagination

  let items = [], flash, waiting

  function fetch () {
    waiting = fetchMore()
      .then(() => items = pagination.items)
      .catch(err => flash = err)
  }

  function onBottomEnteringViewport (e) {
    if (allowMore && hasMore()) fetch()
  }

  if (!allowMore) {
    // Fetch only once at initialization
    fetch()
  }
</script>

<svelte:component this={Component} {items} {...componentProps} />

<div class="bottom" use:viewport on:enterViewport={onBottomEnteringViewport}>
  {#await waiting}<Spinner />{/await}
  <Flash state={flash} />
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .bottom{
    @include display-flex(column, center, center);
  }
</style>
