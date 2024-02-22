<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { user } from '#user/user_store'
  import { autosize } from '#lib/components/actions/autosize'
  import { getActionKey } from '#lib/key_events'
  import isMobile from '#lib/mobile_check'
  import Flash from '#lib/components/flash.svelte'
  import { postTransactionMessage } from '#transactions/lib/helpers'
  import Spinner from '#components/spinner.svelte'

  export let transaction

  let message, flash, sending

  function onKeyDown (e) {
    if (e.ctrlKey && getActionKey(e) === 'enter') {
      sendMessage()
    }
  }
  async function sendMessage () {
    try {
      sending = true
      flash = null
      transaction = await postTransactionMessage({
        transaction,
        message,
      })
      message = ''
    } catch (err) {
      flash = err
    } finally {
      sending = false
    }
  }
</script>

<form class="new-message">
  <div class="main">
    <div class="avatar">
      <img src={imgSrc($user.picture, 50)} alt={$user.username} />
    </div>
    <textarea
      class="message"
      name="message"
      placeholder={I18n('your message…')}
      on:keydown={onKeyDown}
      use:autosize
      bind:value={message}
    />
  </div>
  <Flash state={flash} />
  <div class="bottom">
    {#if !isMobile}
      <span class="shortcut-tip">{i18n('Ctrl+Enter to send')}</span>
    {/if}
    <button
      class="tiny-success-button"
      on:click={sendMessage}
      disabled={message?.length === 0 || sending}
    >
      {#if sending}<Spinner />{/if}
      {I18n('send')}
    </button>
  </div>
</form>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#general/scss/shortcut_tip';
  .new-message{
    padding: 1em;
    @include display-flex(column);
  }
  .main{
    @include display-flex(row, flex-start, space-between);
    .avatar{
      flex: 0 0 auto;
    }
    textarea{
      flex: 1 1 auto;
      border: solid 1px #ccc;
    }
  }
  .bottom{
    @include display-flex(row, center, flex-end);
  }
  .shortcut-tip{
    color: grey;
    font-size: 0.9em;
    padding: 0;
    margin: 0;
    text-align: end;
    padding-block-start: 0.2em;
    padding-block-end: 0.2em;
    margin-inline-end: 1em;

    /* Small screens */
    @media screen and (max-width: $small-screen){
      // doing shortcuts in mobile is quite hard
      display: none;
    }
  }
</style>
