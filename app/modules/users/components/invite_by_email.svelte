<script lang="ts">
  import { uniq } from 'underscore'
  import { autosize } from '#app/lib/components/actions/autosize'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { i18n, I18n } from '#user/lib/i18n'
  import UserLi from '#users/components/user_li.svelte'
  import { sendEmailInvitations } from '#users/invitations'

  export let message = ''
  export let group = null

  let flash, rawEmails
  let emailsInvited = []
  let usersAlreadyThere = []

  async function sendInvitations () {
    try {
      const res = await sendEmailInvitations({ emails: rawEmails, message, group: group?._id })
      usersAlreadyThere = usersAlreadyThere.concat(res.users)
      emailsInvited = uniq(emailsInvited.concat(res.emails))
    } catch (err) {
      flash = err
    }
  }
</script>

<div class="invite-by-email">
  {#if !group}
    <h3>{@html icon('envelope')} {I18n('invite friends by email')}</h3>
  {/if}

  <label class="invitations">
    {I18n('email address')}
    <textarea
      name="invitations"
      placeholder={i18n('emails separated by a comma')}
      use:autosize
      bind:value={rawEmails}
    />
  </label>

  <label>
    {i18n('personalized message')}
    <textarea
      name="message"
      placeholder="({i18n('optional')})"
      use:autosize
      bind:value={message}
    />
  </label>

  <button on:click={sendInvitations} class="button light-blue bold radius send">
    {@html icon('send')}
    {I18n('send invitations')}
  </button>

  {#if emailsInvited.length > 0}
    <div class="output" role="alert">
      <ul class="email-sent">
        {#each emailsInvited as email (email)}
          <li>
            <!-- emails are escaped during validation -->
            {@html I18n('email_invitation_sent', { email })}
            {@html icon('check-circle')}
          </li>
        {/each}
      </ul>
    </div>
  {/if}

  {#if usersAlreadyThere?.length > 0}
    <div class="users-already-there" aria-live="polite">
      <p>
        {i18n('Look who was already there!')}
        {#if group}
          {I18n('invitation sent')}
        {:else}
          {I18n('friend request sent')}
        {/if}
      </p>
      <ul id="users-already-there">
        {#each usersAlreadyThere as user}
          <!-- TODO: recover user relations or group actions -->
          <UserLi {user} showEmail={true} />
        {/each}
      </ul>
    </div>
  {/if}
</div>

<Flash state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  .invite-by-email{
    padding: 0.5em;
  }
  h3{
    text-align: center;
  }
  textarea{
    margin: 0;
  }
  label{
    text-align: start;
    font-size: 1em;
  }
  .invitations, [name="message"]{
    margin-block-end: 1em;
  }
  .send{
    display: block;
    margin: 0.5em auto;
    align-self: center;
  }
  .email-sent{
    li{
      @include display-flex(row, center, center, wrap);
    }
    :global(.email){
      font-weight: bold;
      padding-inline-start: 0.2em;
    }
    :global(.fa-check-circle){
      font-size: 1.4rem;
      color: $success-color;
    }
  }
  .users-already-there{
    padding-block: 1.2em;
    p{
      padding-block-end: 0.6em;
    }
  }
</style>
