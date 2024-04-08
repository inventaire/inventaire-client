<script lang="ts">
  import { icon } from '#lib/icons'
  import { I18n } from '#user/lib/i18n'

  export let candidates

  const checkAll = checked => candidates = candidates.map(candidate => ({ ...candidate, checked }))
</script>
<div class="candidates-nav">
  <button
    class="grey-button"
    on:click={() => checkAll(true)}
    name={I18n('select all')}
  >
    {I18n('select all')}
  </button>
  <button
    class="grey-button"
    on:click={() => checkAll(false)}
    name={I18n('unselect all')}
  >
    {I18n('unselect all')}
  </button>
  <button
    class="grey-button"
    on:click={() => candidates = []}
    name={I18n('empty the queue')}
  >
    <!-- TODO: insert "are you sure" popup -->
    {@html icon('trash')}
    {I18n('empty the queue')}
  </button>
</div>
<style lang="scss">
  @import "#general/scss/utils";
  .candidates-nav{
    @include display-flex(row, center, center, wrap);
    button{
      @include radius;
      margin: 0.1em;
      flex: 1 0 0;
      padding: 0.5em;
      word-wrap: break-word;
      min-width: 10em;
    }
  }
</style>
