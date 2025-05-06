<script lang="ts">
  import { icon } from '#app/lib/icons'
  import { reqres } from '#app/radio'
  import { I18n } from '#user/lib/i18n'

  let validationEmailRequested = false

  async function emailConfirmationRequest () {
    validationEmailRequested = true
    try {
      await reqres.request('email:confirmation:request')
    } catch (err) {
      validationEmailRequested = false
      throw err
    }
  }
</script>

{#if validationEmailRequested}
  <p>
    {@html icon('check')}
    {@html I18n('new_confirmation_email')}
  </p>
{:else}
  <p>
    {@html icon('warning')}
    {@html I18n('email_wasnt_verified')}
  </p>
  <button class="light-blue-button radius" on:click={emailConfirmationRequest}>
    {@html I18n('email_confirmation_error_button')}
  </button>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  p{
    margin-block-start: 1rem;
  }
  button{
    margin-block-start: 0.5rem;
  }
</style>
