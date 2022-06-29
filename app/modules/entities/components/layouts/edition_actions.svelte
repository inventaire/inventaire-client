<script>
  import { i18n } from '#user/lib/i18n'
  import { isOpenedOutside } from '#lib/utils'
  import Link from '#lib/components/link.svelte'

  export let entity

  const url = `/entity/${entity.uri}/add`

  function onClick (e) {
    e.stopPropagation()
    if (!(isOpenedOutside(e))) {
      app.navigateAndLoad(url)
      e.preventDefault()
    }
  }
</script>
<button
  class="add action-button tiny-button"
  on:click={onClick}
>
  <Link
    {url}
    text={i18n('add to inventory')}
    light={true}
    icon='plus'
  />
</button>
<style lang="scss">
  @import '#general/scss/utils';
  .action-button{
    @include tiny-button($light-blue);
    padding: 0.5em;
    white-space: nowrap;
  };
</style>
