<script lang="ts">
  import autosize from 'autosize'
  import { autofocus } from '#app/lib/components/actions/autofocus'
  import type { FlashState } from '#app/lib/components/flash.svelte'
  import { userContent } from '#app/lib/handlebars_helpers/user_content'
  import { icon } from '#app/lib/icons'
  import { getActionKey } from '#app/lib/key_events'
  import type { SerializedUser } from '#app/modules/users/lib/users'
  import Spinner from '#components/spinner.svelte'
  import { updateElement, type ListingElementWithEntity } from '#listings/lib/listings'
  import { I18n, i18n } from '#user/lib/i18n'

  export let element: ListingElementWithEntity
  export let creator: SerializedUser
  export let flash: FlashState
  export let isCreatorMainUser: boolean

  const { username } = creator

  let isEditMode, validating
  let newComment = element.comment

  async function validate () {
    validating = _updateElement()
    await validating
    validating = null
    toggleEditMode()
  }

  function onKeyDown (e) {
    const key = getActionKey(e)
    if (key === 'esc') isEditMode = false
    else if (e.ctrlKey && key === 'enter') validate()
    e.stopPropagation()
  }

  function toggleEditMode () {
    isEditMode = !isEditMode
    flash = null
  }

  $: comment = element.comment
  async function _updateElement () {
    flash = null
    try {
      await updateElement({ id: element._id, comment: newComment })
      element.comment = newComment
    } catch (err) {
      flash = err
    }
  }
</script>
<div class="listing-element-comment">
  {#if isEditMode}
    <label>
      {i18n('Comment by %{username}', { username })}
      <textarea
        type="text"
        bind:value={newComment}
        use:autosize
        use:autofocus
        on:keydown={onKeyDown}
      />
    </label>
    <div class="button-group-right">
      <button
        class="tiny-button cancel"
        on:click={toggleEditMode}
      >
        {I18n('cancel')}
      </button>

      <button
        class="tiny-button validate success"
        title={I18n('validate')}
        disabled={validating}
        on:click={validate}
      >
        {#if validating}
          <Spinner />
        {:else}
          {@html icon('check')}
          {I18n('save')}
        {/if}
      </button>
    </div>
  {:else}
    {#if isCreatorMainUser}
      <button
        on:click={toggleEditMode}
        title={i18n('edit')}
        class="edit-button"
      >
        <div class="comment-header">
          <span class="section-label">{i18n('Comment by %{username}', { username })}</span>
          {@html icon('pencil')}
        </div>
        {#if comment}
          <p class="comment">
            {@html userContent(comment)}
          </p>
        {/if}
      </button>
    {:else}
      {#if comment}
        <p class="section-label">
          {i18n('Comment by %{username}', { username })}
        </p>
        <p>{@html userContent(comment)}</p>
      {/if}
    {/if}
  {/if}
</div>
<style lang="scss">
  @import "#general/scss/utils";
  .listing-element-comment{
    background-color: $off-white;
    padding: 0.5em 1em;
    margin-block-start: 1.5em;
    @include radius;
  }
  .edit-button{
    width: 100%;
    :global(.fa){
      opacity: 0.5;
      @include transition(opacity);
    }
    &:hover{
      :global(.fa){
        opacity: 1;
      }
    }
  }
  .comment-header{
    width: 100%;
    @include display-flex(row, center, space-between);
  }
  .comment{
    text-align: start;
    font-size: 1rem;
    margin-block-start: 0.5em;
  }
  .section-label{
    color: $soft-grey;
  }
</style>
