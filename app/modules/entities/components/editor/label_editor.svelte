<script lang="ts">
  import { isString } from 'underscore'
  import { autofocus } from '#app/lib/components/actions/autofocus'
  import { I18n, i18n } from '#modules/user/lib/i18n'
  import EditModeButtons from './edit_mode_buttons.svelte'

  export let currentValue: string
  export let matchingSerieLabel: boolean
  export let serieUri: boolean
  export let showDelete: boolean
  export let deleteButtonDisable: boolean
  export let input: HTMLElement = null
  export let onInputKeyup: (e: Event) => void
  export let closeEditMode: () => void
  export let saveFromInput: () => void
  export let deleteLabel: () => void
</script>

<div class="label-editor-input">
  <input
    type="text"
    value={isString(currentValue) ? currentValue : ''}
    use:autofocus
    on:keyup={onInputKeyup}
    bind:this={input}
  />
  {#if matchingSerieLabel}
    <p class="tip">
      {@html I18n('title_matches_serie_label_tip', {
        pathname: `/entity/${serieUri}/edit`,
      })}
    </p>
  {/if}
</div>
<EditModeButtons
  on:cancel={closeEditMode}
  on:save={saveFromInput}
  on:delete={deleteLabel}
  {showDelete}
  deleteButtonDisableMessage={deleteButtonDisable ? i18n('There should be at least one label') : null}
/>

<style lang="scss">
  @import '#general/scss/utils';
  @import "#entities/scss/title_tip";

  .label-editor-input{
    position: relative;
  }
  /* Small screens */
  @media screen and (width < $small-screen){
    input{
      margin: 0;
    }
  }
</style>
