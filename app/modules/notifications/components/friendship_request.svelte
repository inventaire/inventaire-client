<script lang="ts">
  import Flash, { type FlashState } from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { loadInternalLink } from '#app/lib/utils'
  import Spinner from '#components/spinner.svelte'
  import { I18n } from '#user/lib/i18n'
  import UserLi from '#users/components/user_li.svelte'
  import { updateRelationStatus } from '#users/lib/relations'
  import type { SerializedUser } from '#users/lib/users'

  export let user: SerializedUser

  let flash: FlashState

  let accepting = false
  let done = false
  async function accept () {
    try {
      accepting = true
      await updateRelationStatus(user, 'accept')
    } catch (err) {
      flash = err
    } finally {
      accepting = false
      onceDone()
    }
  }

  let discarding = false
  async function discard () {
    try {
      discarding = true
      await updateRelationStatus(user, 'discard')
    } catch (err) {
      flash = err
    } finally {
      discarding = false
      onceDone()
    }
  }

  function onceDone () {
    flash = { type: 'success', message: '', canBeClosed: false }
    done = true
    setTimeout(() => flash = null, 1000)
  }
</script>

<UserLi {user}>
  <div class="actions">
    {#if flash}
      <Flash bind:state={flash} />
    {:else if done}
      <a href={user.pathname} on:click={loadInternalLink} class="action tiny-button light-blue">
        {I18n('see profile')}
      </a>
    {:else}
      <button
        class="accept action tiny-button success"
        title={I18n('accept friend request')}
        on:click={accept}
        disabled={accepting || discarding}
      >
        {#if accepting}
          <Spinner light={true} />
        {:else}
          {@html icon('check')}
        {/if}
        <span class="label"> {I18n('confirm')}</span>
      </button>

      <button
        class="discard action tiny-button"
        title={I18n('discard friend request')}
        on:click={discard}
        disabled={accepting || discarding}
      >
        {#if discarding}
          <Spinner light={true} />
        {:else}
          {@html icon('minus')}
        {/if}
        <span class="label"> {I18n('decline')}</span>
      </button>
    {/if}
  </div>
</UserLi>

<style lang="scss">
  @use '#general/scss/utils';
  .actions{
    :global(.flash){
      padding: 0.2rem 0.6rem;
      margin-inline-end: 0.5em;
    }
  }
  .action{
    @include radius;
  }
  /* Small screens */
  @media screen and (width < 500px){
    .actions{
      @include display-flex(column);
    }
    .action:not(:last-child){
      margin-block: 0.2em;
    }
  }
  /* Large screens */
  @media screen and (width >= 500px){
    .actions{
      @include display-flex(row);
    }
    .action{
      margin-inline-end: 0.5em;
    }
  }
</style>
