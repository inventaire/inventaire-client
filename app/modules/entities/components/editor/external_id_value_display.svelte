<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import Link from '#app/lib/components/link.svelte'
  import Tooltip from '#components/tooltip.svelte'
  import { externalIdsDisplayConfigs } from '#entities/lib/entity_links'
  import { I18n } from '#user/lib/i18n'

  export let value, property

  let url
  if (externalIdsDisplayConfigs[property]) {
    const { getUrl } = externalIdsDisplayConfigs[property]
    if (getUrl) url = getUrl(value)
  }

  const dispatch = createEventDispatcher()
</script>

<button class="value-display" on:click={() => dispatch('edit')} title={I18n('edit')}>
  {#if url}
    <Tooltip>
      <div slot="primary" aria-haspopup="menu">
        {value || ''}
      </div>
      <div slot="tooltip-content" role="menuitem">
        <Link {url} text={url} />
      </div>
    </Tooltip>
  {:else}
    {value || ''}
  {/if}
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
