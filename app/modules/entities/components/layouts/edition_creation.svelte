<script>
  import { i18n } from '#user/lib/i18n'
  import { createEditionFromWork, validateEditionPossibility, addWithoutIsbnPath } from '#entities/components/lib/edition_creation_helpers'
  import { icon, loadInternalLink } from '#lib/utils'
  import Flash from '#lib/components/flash.svelte'
  import { autofocus } from '#lib/components/actions/autofocus'
  import getActionKey from '#lib/get_action_key'

  export let work, editions

  let userInput = ''
  let flash
  let showForm

  const onIsbnButtonClick = async () => {
    flash = null
    try {
      validateEditionPossibility({ userInput, editions })
      const newEdition = await createEditionFromWork({
        workEntity: work,
        userInput,
      })
      editions = [ newEdition, ...editions ]
    } catch (err) {
      flash = err
    }
  }

  function onInputKeyup (e) {
    const key = getActionKey(e)
    if (key === 'esc') showForm = false
  }
</script>
<div class="wrapper">
  <div class="edition-creation">
    {#if showForm}
      <div class="from-isbn">
        <label for="isbn-group">
          {i18n('Add an edition by its ISBN')}
        </label>
        <form class="isbn-group">
          <input
            type="text"
            name="isbn"
            class="has-alertbox enterClick"
            bind:value={userInput}
            placeholder="ex: 2070368228"
            on:keyup={onInputKeyup}
            aria-label="isbn"
            use:autofocus
          >
          <button
            class="isbn-button tiny-button grey"
            on:click={onIsbnButtonClick}
          >
            {@html icon('plus')}
            {i18n('add')}
          </button>
        </form>
      </div>
      <a
        href={addWithoutIsbnPath(work)}
        class="without-isbn tiny-button grey"
        on:click={loadInternalLink}
        >
        {@html icon('plus')}
        {i18n('add an edition without an ISBN')}
      </a>
    {:else}
      <button
        class="tiny-button show-form"
        on:click={() => showForm = true}
      >
        {@html icon('plus')}
        {i18n('add a missing edition')}
      </button>
    {/if}
  </div>
  <Flash bind:state={flash}/>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .wrapper{
    border-top: 1px solid #ddd;
    padding: 1em 0.5em 0.5em 0.5em;
    margin-top: 0.5em;
    align-self: stretch;
  }
  .edition-creation{
    @include display-flex(column, stretch, center);
    @include radius;
    max-width: 20em;
    margin: 0 auto;
  }
  .isbn-group{
    @include display-flex(row);
    input{
      @include radius-right(0);
    }
    .tiny-button{
      @include radius-left(0);
    }
    margin-bottom: 0.5em;
  }
  .isbn-button{
    white-space: nowrap;
  }
  .without-isbn{
    padding: 0.5em;
    line-height: 1rem;
    text-align: center;
  }
  .show-form{
    padding: 0.5em;
    max-width: 20em;
  }
</style>
