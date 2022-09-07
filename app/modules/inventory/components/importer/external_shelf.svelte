<script>
  import { I18n } from '#user/lib/i18n'
  export let externalShelf

  const toggleCheckbox = () => externalShelf.checked = !externalShelf.checked

  $: checked = externalShelf.checked
</script>
<li class='external-shelf' on:click={toggleCheckbox}>
  <input type="checkbox" bind:checked name="{I18n('external_shelf')}">
  <p>{externalShelf.name}</p>
</li>
<style lang="scss">
  @import '#general/scss/utils';
  .external-shelf{
    @include display-flex(row, center);
    cursor: pointer;
  }
  input{
    margin-right: 0.5em;
  }
</style>
