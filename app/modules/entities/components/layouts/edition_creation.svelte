<script lang="ts">
  import { autofocus } from '#app/lib/components/actions/autofocus'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { getActionKey } from '#app/lib/key_events'
  import { loadInternalLink } from '#app/lib/utils'
  import { commands } from '#app/radio'
  import Spinner from '#components/spinner.svelte'
  import { createEditionFromWork, validateEditionPossibility, addWithoutIsbnPath } from '#entities/components/lib/edition_creation_helpers'
  import type { SerializedEntity } from '#entities/lib/entities'
  import { i18n, I18n } from '#user/lib/i18n'

  export let work: SerializedEntity
  export let editions: SerializedEntity[]

  let userInput = ''
  let flash
  let showForm
  let creatingFromIsbn = false

  const onIsbnButtonClick = async () => {
    creatingFromIsbn = true
    flash = null
    try {
      validateEditionPossibility(userInput, editions)
      const newEdition = await createEditionFromWork({
        workEntity: work,
        userInput,
      })
      commands.execute('show:entity', newEdition.uri)
    } catch (err) {
      flash = err
    } finally {
      creatingFromIsbn = false
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
            class="has-alertbox"
            bind:value={userInput}
            placeholder="ex: 2070368228"
            on:keyup={onInputKeyup}
            aria-label="isbn"
            use:autofocus
          />
          <button
            class="isbn-button tiny-button grey"
            disabled={creatingFromIsbn}
            on:click={onIsbnButtonClick}
          >
            {#if creatingFromIsbn}
              <Spinner />
            {:else}
              {@html icon('plus')}
            {/if}
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
        {I18n('add an edition without an ISBN')}
      </a>
    {:else}
      <button
        class="tiny-button show-form"
        on:click={() => showForm = true}
      >
        {@html icon('plus')}
        {I18n('add a missing edition')}
      </button>
    {/if}
  </div>
  <Flash bind:state={flash} />
</div>
<style lang="scss">
  @import "#general/scss/utils";
  .wrapper{
    padding: 1em 0.5em 0.5em;
    align-self: stretch;
  }
  .edition-creation{
    @include display-flex(column, stretch, center);
    @include radius;
    max-inline-size: 20em;
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
    margin-block-end: 0.5em;
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
    max-inline-size: 20em;
  }
</style>
