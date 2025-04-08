<script lang="ts">
  import { debounce } from 'underscore'
  import { config } from '#app/config'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { i18n } from '#user/lib/i18n'
  import { mainUserStore, updateUser } from '#user/lib/main_user'

  const name = 'anonymize'
  const { publicHost } = config

  let flash

  let value = $mainUserStore.settings.contributions.anonymize

  async function updateSetting () {
    flash = null
    try {
      await updateUser('settings.contributions.anonymize', value)
    } catch (err) {
      flash = err
    }
  }

  const lazyUpdateSetting = debounce(updateSetting, 2000)
</script>

<label>
  <input
    type="checkbox"
    {name}
    id={name}
    bind:checked={value}
    on:change={lazyUpdateSetting}
  />
  {i18n('Anonymize contributions')}
</label>

<div class="public-contributions-note" class:anonymize={value}>
  {#if value}
    {@html icon('user-secret')}
    {i18n('Contribution anonymization is enabled: only %{instance} administrators can see the list of your edits on bibliographic data.', { instance: publicHost })}
  {:else}
    {@html icon('globe')}
    {i18n('Contribution anonymization is disabled: anyone can see the list of your edits on bibliographic data.')}
  {/if}
  {i18n('This setting does not affect the visibility of your inventory items.')}
</div>

<Flash bind:state={flash} />

<style lang="scss">
  @use "#general/scss/utils";
  input{
    margin: 0;
  }
  label{
    display: block;
    font-size: 1rem;
    margin: 1em 0 0.5em;
  }
  .public-contributions-note{
    padding: 0.5rem;
    margin-block-end: 1rem;
    @include radius;
    &.anonymize{
      background-color: $dark-grey;
      color: white;
    }
    &:not(.anonymize){
      background-color: $off-white;
      color: $dark-grey;
    }
  }
</style>
