<script lang="ts">
  import app from '#app/app'
  import { icon } from '#app/lib/icons'
  import Modal from '#components/modal.svelte'
  import RequestItem from '#transactions/components/request_item.svelte'
  import { hasOngoingTransactionsByItemIdSync } from '#transactions/lib/helpers'
  import { i18n, I18n } from '#user/lib/i18n'

  export let item
  export let user

  const { _id: itemId, restricted, transaction, busy } = item

  let hasActiveTransaction = false
  if (app.user.loggedIn) {
    hasActiveTransaction = hasOngoingTransactionsByItemIdSync(itemId)
  }
  let showRequestItemModal
</script>

{#if restricted}
  {#if busy}
    <div class="busy-box">
      {@html icon('sign-out')}{i18n('unavailable')}
    </div>
  {:else}
    {#if hasActiveTransaction}
      <span class="main-user-requested">
        {i18n('main_user_requested')}
      </span>
    {:else}
      {#if transaction !== 'inventorying'}
        <button on:click={() => showRequestItemModal = true}>
          {@html icon('comments')}
          {I18n('send request')}
        </button>
      {/if}
    {/if}
  {/if}
{/if}

{#if showRequestItemModal}
  <Modal on:closeModal={() => showRequestItemModal = false}>
    <RequestItem {item} {user} />
  </Modal>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  button{
    // just 'height' wasnt working on chrome
    min-height: $user-box-heigth;
    max-height: $user-box-heigth;
    font-weight: normal;
    @include bg-hover($light-grey, 10%);
    @include text-hover($dark-grey, $darker-grey);
    transition: color 0.3s ease, background-color 0.3s ease;
    width: 100%;
    @include display-flex(row, center, center);
  }
  .main-user-requested, .busy-box{
    min-height: $user-box-heigth;
    width: 100%;
    @include display-flex(row, center, center);
  }
  .busy-box{
    background-color: #444;
    color: white;
  }
</style>
