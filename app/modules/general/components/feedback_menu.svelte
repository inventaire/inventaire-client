<script lang="ts">
  import { tick } from 'svelte'
  import { slide } from 'svelte/transition'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { onChange } from '#app/lib/svelte/svelte'
  import { contact } from '#app/lib/urls'
  import { postFeedback } from '#general/lib/feedback'
  import type { EntityUri } from '#server/types/entity'
  import { i18n, I18n } from '#user/lib/i18n'
  import { mainUser, mainUserStore } from '#user/lib/main_user'
  import Spinner from './spinner.svelte'

  export let subject = ''
  export let uris: EntityUri[] = null
  export let standalone = true

  let unknownUser, flash
  let message = ''
  let sending = false
  let showConfirmation = false

  async function sendFeedback () {
    try {
      subject = subject.trim()
      message = message.trim()
      sending = true
      await postFeedback({
        subject,
        message,
        unknownUser,
        uris,
      })
      subject = ''
      message = ''
      await tick()
      showConfirmation = true
    } catch (err) {
      flash = err
    } finally {
      sending = false
    }
  }

  function hideConfirmation () {
    showConfirmation = false
  }

  $: onChange(subject, message, hideConfirmation)
</script>

<div class="feedback-menu" class:standalone>
  <div>
    <h3>{I18n('feedback_title')}</h3>
    <p>{i18n('feedback_intro')}</p>
    <form>
      <div class="from">
        {#if mainUser}
          <span class="label">{i18n('from:')}</span>
          <span class="username">{$mainUserStore.username}</span>
        {:else}
          <input
            type="email"
            name="email"
            class="radius"
            placeholder="{i18n('from')}..."
            bind:value={unknownUser}
          />
        {/if}
      </div>
      <div class="to">
        <span class="label">{i18n('to:')}</span>
        <span class="email">{contact.email}</span>
      </div>

      <label for="subject">{I18n('subject')}</label>
      <input
        type="text"
        id="subject"
        name="subject"
        placeholder="{I18n('subject')}..."
        class="radius"
        required
        bind:value={subject}
      />

      <label for="feedback">{I18n('message')}</label>
      <textarea
        id="message"
        name="feedback"
        placeholder="{I18n('your message')}..."
        required
        bind:value={message}
      />

      <div>
        <button on:click={sendFeedback} class="button light-blue radius bold" disabled={sending || !subject.trim() || !message.trim()}>
          {#if sending}
            <Spinner light={true} />
          {:else}
            {@html icon('send')}
          {/if}
          {I18n('send feedback')}
        </button>
      </div>
    </form>

    <Flash state={flash} />

    {#if showConfirmation}
      <p class="confirmation" role="alert" transition:slide>
        {@html icon('check')}
        {i18n('Thank you for your message! Coming back to you shortly')}
      </p>
    {/if}

    <div class="get-involved">
      <h5>{@html i18n('get_involved')}</h5>
      <p>{@html i18n('contribution_ideas')}</p>
    </div>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';

  .feedback-menu{
    text-align: center;
    &.standalone{
      @include central-column(40em);
      > div{
        background-color: white;
        padding: 1em;
      }
      /* Large screens */
      @media screen and (width >= $small-screen){
        padding-block-start: 1em;
      }
    }
  }
  .username, .email{
    font-weight: bold;
    color: $dark-grey;
    @include serif;
  }
  p{
    max-width: 30em;
    margin: auto;
    text-align: center;
  }
  label, .label{
    font-size: 1rem;
    text-align: start;
  }
  .confirmation{
    color: white;
    background-color: $success-color;
    @include radius;
    padding: 0.5em;
    margin-block-start: 2em;
  }
  .get-involved{
    margin-block-start: 2em;
    :global(.link){
      text-decoration: underline;
    }
  }
  /* Large screens */
  @media screen and (width >= $small-screen){
    .feedback-menu{
      padding: 1em;
    }
    .from, .to{
      text-align: start;
    }
    .from .label, .from input, .to .label{
      display: inline;
    }
    .from{
      input{
        margin-block-start: 1em;
      }
    }
    .to{
      margin-block-end: 1em;
    }
  }
</style>
