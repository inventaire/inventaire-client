<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import Link from '#app/lib/components/link.svelte'
  import Tooltip from '#components/tooltip.svelte'
  import { I18n } from '#user/lib/i18n'

  export let value

  const dispatch = createEventDispatcher()
</script>

<button class="value-display" on:click={() => dispatch('edit')} title={I18n('edit')}>
  <Tooltip>
    <div slot="primary" aria-haspopup="menu">
      {value || ''}
    </div>
    <div slot="tooltip-content" role="menuitem">
      <Link url={value} text={I18n('Open this link outside')} />
    </div>
  </Tooltip>
</button>

<style lang="scss">
  @import "#general/scss/utils";

  .value-display{
    flex: 1;
    align-self: stretch;
    cursor: pointer;
    text-align: start;
    @include bg-hover(white, 5%);
    user-select: text;
    font-weight: normal;
  }
</style>
