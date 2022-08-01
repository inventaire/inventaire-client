<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { userContent } from '#lib/handlebars_helpers/user_content'
  import { autofocus } from '#lib/components/actions/autofocus'
  import { autosize } from '#lib/components/actions/autosize'
  import getActionKey from '#lib/get_action_key'

  export let item, flash

  let { notes = '' } = item

  let editMode = false

  async function save () {
    editMode = false
    try {
      await app.request('items:update', {
        items: [ item ],
        attribute: 'notes',
        value: notes,
      })
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
          <p>{userContent(notes)}</p>
        </button>
    </div>
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .item-notes{
    background-color: $dark-grey;
    padding: 0.5em;
    margin: 0.4em 0 0.6em 0;
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
    }
  }
  .tiny-button{
    line-height: inherit;
  }
  .header{
    @include display-flex(row, center);
  }
  .indicator{
    margin-left: auto;
  }
</style>
