<script>
  import { icon } from '#lib/handlebars_helpers/icons'
  // import ListEditor from '#modules/lists/components/list_editor.svelte'
  import { createList } from '#modules/lists/lib/lists'
  import { I18n, i18n } from '#user/lib/i18n'

  export let list = {}

  async function create () {
    const res = await createList(list)
    list = res.list
  }
</script>

<form>
  <label>
    <span>{i18n('List name')}</span>
    <input type="text" placeholder={i18n('ex: "My favorite cook books"')} bind:value={list.name}>
  </label>
  <button
    on:click={create}
    class="tiny-button light-blue"
    >
    {@html icon('plus')}
    {I18n('create')}
  </button>
</form>

<style lang="scss">
  @import '#general/scss/utils';

  form{
    @include display-flex(row, center, center);
    max-width: 30em;
    flex: 1 0 auto;
  }
  label{
    @include display-flex(row, center, center);
    margin: 0 0.5em;
    white-space: nowrap;
  }
  input{
    max-width: 20em;
    margin: 0;
    margin-left: 0.5em;
  }
  .tiny-button{
    padding: 0.5em;
    white-space: nowrap;
  }
</style>
