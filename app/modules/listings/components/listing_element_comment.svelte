<script lang="ts">
  import autosize from 'autosize'
  import { userContent } from '#app/lib/handlebars_helpers/user_content'
  import { icon } from '#app/lib/icons'
  import { getActionKey } from '#app/lib/key_events'
  import Spinner from '#components/spinner.svelte'
  import { updateElement } from '#listings/lib/listings'
  import { I18n, i18n } from '#user/lib/i18n'

  export let isCreatorMainUser, flash, element

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
      {I18n('comment')}
      <textarea
        type="text"
        bind:value={newComment}
        use:autosize
        on:keydown={onKeyDown}
      />
    </label>
    <div class="button-group-right">
      <button
        class="tiny-button cancel"
        on:click={toggleEditMode}
      >
        {i18n('cancel')}
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
        <div class="comment-wrapper">
          <p class="section-label">
            {I18n('comment')}
          </p>
          {#if comment}
            <p>{@html userContent(comment)}</p>
          {/if}
        </div>
        <span>
          {@html icon('pencil')}
        </span>
      </button>
    {:else}
      {#if comment}
        <p class="section-label">
          {I18n('comment')}
        </p>
        <p>{@html userContent(comment)}</p>
      {/if}
    {/if}
  {/if}
</div>
<style lang="scss">
  @import "#general/scss/utils";
  .edit-button{
    @include display-flex(row, flex-start, space-between);
    width: 100%;
  }
  .comment-wrapper{
    text-align: start;
  }
  .section-label{
    color: $soft-grey;
  }
  .listing-element-comment{
    background-color: $off-white;
    padding: 0.5em 1em;
    margin: 0.4em 0 0.6em;
    @include radius;
  }
</style>
