<script context="module" lang="ts">
  import type { Url } from '#server/types/common'
  import type { AriaRole } from 'svelte/elements'

  const types = {
    success: { iconName: 'check' },
    info: { iconName: 'info-circle' },
    support: { iconName: 'support' },
    warning: { iconName: 'warning' },
    error: { iconName: 'warning' },
  }

  export type FlashType = keyof typeof types

  interface FlashStateCommons {
    role?: AriaRole
    duration?: number
    canBeClosed?: boolean
  }

  interface FlashLink {
    url: Url
    text: string
  }

  interface FlashStateMessage extends FlashStateCommons {
    type: FlashType
    message: string
    link?: FlashLink
  }

  interface FlashStateHtml extends FlashStateCommons {
    type: FlashType
    html: string
    link?: FlashLink
  }

  interface LoadingFlash extends FlashStateCommons {
    type: 'loading'
    message?: string
  }

  export type FlashState = FlashStateMessage | FlashStateHtml | LoadingFlash | Error
</script>

<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import Link from '#app/lib/components/link.svelte'
  import { icon } from '#app/lib/icons'
  import log_ from '#app/lib/loggers'
  import Spinner from '#general/components/spinner.svelte'
  import { I18n } from '#user/lib/i18n'

  export let state: FlashState = null

  let type, iconName

  const findIcon = type => types[type]?.iconName

  $: {
    if (state instanceof Error) {
      type = 'error'
      iconName = findIcon(type)
      // Logs the error and report it
      log_.error(state)
      state.message ||= I18n('something went wrong :(')
    } else {
      type = state?.type
      iconName = findIcon(type)
    }
    if (state && 'duration' in state) {
      const stateToRemove = state
      setTimeout(() => {
        if (state === stateToRemove) closeFlash()
      }, state.duration)
    }
  }

  const dispatch = createEventDispatcher()

  function closeFlash () {
    state = null
    dispatch('close')
  }
</script>

{#if state}
  <div class="flash {type}">
    <div role={'role' in state ? state.role : (type === 'error' ? 'alert' : 'status')}>
      {#if type === 'loading'}
        <Spinner />
        {'message' in state ? state.message : I18n('loading')}
      {:else}
        {#if iconName}{@html icon(iconName)}{/if}
        {#if 'html' in state}
          {@html state.html}
        {:else if 'message' in state}
          {state.message}
        {/if}
        {#if 'link' in state}
          <Link
            url={state.link.url}
            text={state.link.text}
            classNames="classic-link"
          />
        {/if}
      {/if}
    </div>
    {#if !('canBeClosed' in state) || state.canBeClosed !== false}
      <button
        on:click|stopPropagation={closeFlash}
        title={I18n('close')}
      >
        {@html icon('close')}
      </button>
    {/if}
  </div>
{/if}

<style lang="scss">
  @use "#general/scss/utils";
  .flash{
    @include display-flex(row, center, space-between);
    padding: 0.5em;
    margin: 0.3em 0;
    padding-inline-start: 0.5em;
    color: $dark-grey;
    word-break: break-all;
    @include radius;
    > div{
      // Take all the width, so that a parent's "text-align: center" can be applied
      flex: 1;
    }
    button{
      margin: 0.2em;
      padding: 0;
    }
    :global(a){
      text-decoration: underline;
    }
  }
  .error{
    background-color: lighten($danger-color, 25%);
  }
  .success{
    background-color: lighten($success-color, 30%);
  }
  .info, .loading{
    background-color: lighten($primary-color, 70%);
  }
  .warning{
    background-color: lighten($yellow, 35%);
  }
</style>
