<script>
  import { I18n } from '#user/lib/i18n'
  export let externalShelf
</script>
<label>
  <input type="checkbox" bind:checked={externalShelf.checked} name="{I18n('external_shelf')}">
  {externalShelf.name}
</label>
<style lang="scss">
  @import '#general/scss/utils';
  input{
    margin-right: 0.5em;
  }
  label{
    font-size: 1rem;
  }
</style>
