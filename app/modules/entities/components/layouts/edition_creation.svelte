<script>
  import { i18n } from '#user/lib/i18n'
  import { createEditionFromWork, validateEditionPossibility, addWithoutIsbnPath } from '#entities/components/lib/edition_creation_helpers'
  import { icon } from '#lib/utils'
  import Link from '#lib/components/link.svelte'
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
<div class="edition-creation-svelte">
  {#if showForm}
    <div class="from-isbn">
      <label for="isbnGroup">
      	{i18n('Add an edition by its ISBN')}
      </label>
      <form id="isbnGroup" class="inputGroup">
        <div class="inputBox">
          <input type="text"
            id="isbnField"
            name="isbn"
            class="has-alertbox enterClick"
            bind:value={userInput}
            placeholder="ex: 2070368228"
            on:keyup={onInputKeyup}
            aria-label="isbn"
            use:autofocus
          >
        </div>
        <button
          id="isbnButton"
          class="button grey postfix sans-serif"
          on:click={onIsbnButtonClick}
        >
          {@html icon('plus')}
          {i18n('add')}
        </button>
      </form>
    </div>
    <button id="withoutIsbn" class="tiny-button grey">
      <Link
        url={addWithoutIsbnPath(work)}
        text={'add an edition without an ISBN'}
        icon='plus'
        light={true}
      />
    </button>
  {:else}
    <button
      class="tiny-button show-form"
      on:click={() => showForm = true}
    >
      {@html icon('plus')}
      {i18n('add missing edition')}
    </button>
  {/if}

  <Flash bind:state={flash}/>
</div>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .edition-creation-svelte{
    @include display-flex(row, flex-start, flex-start, wrap);
    @include radius;
    margin: 1em;
    flex-direction: column;
    align-items: stretch;
    max-width:20em;
  }
  .wrapper{
    @include display-flex(row, center, center);
  }
  #isbnButton{
    @include display-flex(row, center, center);
    white-space: nowrap;
    // avoid .postfix to put button above langauge dropdown menu
    z-index:0
  }
  #withoutIsbn{
    @include display-flex(row, center, center);
    font-size: 0.9em;
    padding: 0.5em;
  }
  .show-form{
    padding: 0.3em;
    max-width:20em;
    font-size: 0.9em;
  }
</style>
