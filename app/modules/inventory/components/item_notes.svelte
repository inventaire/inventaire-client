<script lang="ts">
  import { autofocus } from '#app/lib/components/actions/autofocus'
  import { autosize } from '#app/lib/components/actions/autosize'
  import type { FlashState } from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { getActionKey } from '#app/lib/key_events'
  import { userContent } from '#app/lib/user_content'
  import { updateItems } from '#inventory/lib/item_actions'
  import type { SerializedItem } from '#inventory/lib/items'
  import { i18n, I18n } from '#user/lib/i18n'

  export let item: SerializedItem
  export let flash: FlashState = null

  let { notes = '' } = item

  let editMode = false

  async function save () {
    editMode = false
    try {
      await updateItems({
        items: [ item ],
        attribute: 'notes',
        value: notes,
      })
      item.notes = notes
    } catch (err) {
      flash = err
    }
  }

  function onKeyDown (e) {
    const key = getActionKey(e)
    if (key === 'esc') editMode = false
    else if (e.ctrlKey && key === 'enter') save()
    e.stopPropagation()
  }
</script>

<div class="item-notes">
  <div class="header">
    <span class="section-label">{I18n('private notes')}</span>
    <span class="indicator" title={i18n('this is visible by anyone who can see this item')}>
      {@html icon('lock')}
    </span>
    <button
      title={i18n('edit')}
      on:click={() => editMode = true}
    >
      {@html icon('pencil')}
    </button>
  </div>
  {#if editMode}
    <textarea
      placeholder={`(${i18n('notes_placeholder')})`}
      bind:value={notes}
      use:autofocus
      use:autosize
      on:keydown={onKeyDown}
    ></textarea>
    <div class="button-group-right">
      <button
        class="tiny-button cancel"
        on:click={() => editMode = false}
      >
        {i18n('cancel')}
      </button>
      <button
        class="tiny-button success"
        on:click={save}
      >
        {i18n('save')}
      </button>
    </div>
  {:else}
    <div class="text">
      <button
        on:click={() => editMode = true}
        title={i18n('edit')}
      >
        <p>{@html userContent(notes)}</p>
      </button>
    </div>
  {/if}
</div>

<style lang="scss">
  @use "#general/scss/utils";
  .item-notes{
    background-color: $dark-grey;
    padding: 0.5em 1em;
    margin: 0.4em 0 0.6em;
    @include radius;
    &, .text button, :global(.fa){
      color: white;
    }
  }
  .section-label{
    color: $soft-grey;
  }
  .text{
    button{
      display: block;
      padding: 0;
      p{
        text-align: start;
      }
    }
  }
  .tiny-button{
    line-height: inherit;
  }
  .header{
    @include display-flex(row, center);
  }
  .indicator{
    margin-inline-start: auto;
  }
</style>
