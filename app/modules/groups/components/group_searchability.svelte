<script lang="ts">
  import { slide } from 'svelte/transition'
  import { icon } from '#app/lib/icons'
  import { I18n } from '#user/lib/i18n'

  export let searchable
</script>

<section class="searchability">
  <label>
    <input type="checkbox" bind:checked={searchable} />
    {I18n('appear in search results')}
  </label>
  {#if searchable}
    <p class="searchable warning light" transition:slide>
      {@html icon('search')}
      {I18n('this group appears in public search results')}
    </p>
  {:else}
    <p class="not-searchable warning" transition:slide>
      {@html icon('user-secret')}
      {I18n('only those who get the link or are invited can find this group')}
    </p>
  {/if}
</section>

<style lang="scss">
  @use '#general/scss/utils';
  @use '#groups/scss/group_settings_commons';
  section{
    @include group-settings-checkbox-commons;
  }
</style>
