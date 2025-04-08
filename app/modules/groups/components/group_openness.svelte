<script lang="ts">
  import { slide } from 'svelte/transition'
  import { icon } from '#app/lib/icons'
  import { I18n } from '#user/lib/i18n'

  export let open
</script>

<section class="openness">
  <label>
    <input type="checkbox" bind:checked={open} />
    {I18n('open membership')}
  </label>
  {#if open}
    <p class="opened warning light" transition:slide>
      {@html icon('globe')}
      {I18n('anyone can join the group, no admin validation is required.')}
    </p>
  {:else}
    <p class="closed warning" transition:slide>
      {@html icon('key')}
      {I18n('admins have to accept or refuse requests to join the group')}
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
