<script lang="ts">
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import { autofocus } from '#app/lib/components/actions/autofocus'
  import { autosize } from '#app/lib/components/actions/autosize'
  import Flash, { type FlashState } from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { wait } from '#app/lib/promises'
  import { commands } from '#app/radio'
  import { i18n, I18n } from '#user/lib/i18n'
  import type { ConfirmationModalProps } from '../lib/confirmation_modal'

  export let action: ConfirmationModalProps['action']
  export let confirmationText: string
  export let warningText: string = null

  export let formAction: ConfirmationModalProps['formAction'] = null
  export let back: ConfirmationModalProps['back'] = null
  export let yes: string = 'yes'
  export let no: string = 'no'
  export let yesButtonClass: string = 'alert'
  export let formLabel: string = null
  export let formPlaceholder: string = null

  let flash: FlashState
  let formContent = ''

  async function confirm () {
    try {
      await executeFormAction()
      await action()
      flash = { type: 'success', message: '', canBeClosed: false }
      await wait(600)
      close()
    } catch (err) {
      flash = err
    }
  }

  function close () {
    if (back != null) back()
    else commands.execute('modal:close')
  }

  async function executeFormAction () {
    if (formAction && isNonEmptyArray(formContent.trim())) {
      await formAction(formContent.trim())
    }
  }
</script>

<div class="confirmation-modal">
  {#if back != null}
    <button class="back" on:click={back}>{@html icon('arrow-left')}</button>
  {/if}

  <p>{@html confirmationText}</p>

  {#if warningText}
    <p class="grey">{@html icon('warning')}&nbsp;{@html warningText}</p>
  {/if}

  {#if formLabel}
    <label>
      {I18n(formLabel)}
      <textarea
        placeholder="{I18n(formPlaceholder)}..."
        use:autosize
        use:autofocus
        bind:value={formContent}
      />
    </label>
  {/if}

  <button on:click={close} class="button grey radius bold">{i18n(no)}</button>
  <button on:click={confirm} class="button {yesButtonClass} radius bold">{i18n(yes)}</button>

  <Flash state={flash} />
</div>

<style lang="scss">
  @import '#general/scss/utils';

  .confirmation-modal{
    text-align: center;
  }
  .back{
    position: absolute;
    font-weight: bold;
    font-size: 1.3em;
    color: #aaa;
    inset-block-start: 1.4em;
    inset-inline-start: -0.1em;
  }
  .check{
    margin-block-start: 1em;
  }
  .fa-check-circle{
    font-size: 1.4rem;
    color: $success-color;
  }
  label{
    text-align: start;
    margin-block: 1em;
    font-size: 1em;
  }
  textarea{
    margin-block: 0.5em;
  }
  p{
    margin-block-end: 0.5em;
  }
  .button{
    margin-block-start: 0.5em;
  }
</style>
