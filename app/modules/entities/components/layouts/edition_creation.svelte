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
<div class="edition-creation">
  {#if showForm}
    <div class="from-isbn">
      <label for="isbn-group">
      	{i18n('Add an edition by its ISBN')}
      </label>
      <form id="isbn-group" class="input-group">
        <div class="input-box">
          <input
            type="text"
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
      {i18n('add missing edition')}
    </button>
  {/if}
  <Flash bind:state={flash}/>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .edition-creation{
    @include display-flex(row, flex-start, flex-start, wrap);
    @include radius;
    flex-direction: column;
    align-items: stretch;
    max-width: 20em;
    padding: 0.5em;
  }
  .wrapper{
    @include display-flex(row, center, center);
  }
  #isbnButton{
    @include display-flex(row, center, center);
    white-space: nowrap;
  }
  .without-isbn{
    @include display-flex(row, center, center);
    font-size: 0.9em;
    padding: 0.5em;
  }
  .show-form{
    padding: 0.5em;
    max-width: 20em;
    font-size: 0.9em;
  }
  .input-group{
    width: 100%;
    @include display-flex(row, left, flex-start);
    margin-bottom: 0.5em;
    button.postfix{
      height: 2.2rem;
      white-space: nowrap;
    }
  }
  .input-box{
    flex: 1 1 auto;
    min-width: 60%;
    margin-right: 0.4em;
    input{
      height: 2.2rem;
      padding: 0 0.5em;
      margin-bottom: 0;
    }
  }

  /*Small screens*/
  @media screen and (max-width: $very-small-screen) {
    .input-group{
      flex-direction: column;
      button{
        width: 100%;
      }
    }
    .input-box{
      width: 100%;
    }
  }
</style>
