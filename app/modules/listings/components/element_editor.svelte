<script lang="ts">
  import autosize from 'autosize'
  import { createEventDispatcher } from 'svelte'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import Spinner from '#general/components/spinner.svelte'
  import { updateElement } from '#listings/lib/listings'
  import { I18n, i18n } from '#user/lib/i18n'

  export let element

  let validating, flash
  let comment
  if (element) {
    ;({ comment } = element)
  }

  const dispatch = createEventDispatcher()
  async function validate () {
    flash = null
    try {
      await updateElement(element._id, comment)
        .then(() => {
          dispatch('editorDone')
          element.comment = comment
        })
    } catch (err) {
      flash = err
    }
  }
</script>

<h3>{i18n('Edit element')}</h3>
<label>
  {I18n('comment')}
  <textarea
    type="text"
    bind:value={comment}
    use:autosize
  />
</label>
<div class="buttons">
  {#await validating}
    <Spinner />
  {:then}
    <button
      class="validate button success-button"
      title={I18n('validate')}
      on:click={validate}
    >
      {@html icon('check')}
      {I18n('validate')}
    </button>
  {/await}
</div>
<Flash bind:state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  h3{
    text-align: center;
  }
  label{
    font-size: 1rem;
    margin-block-end: 0.2em;
  }
  .buttons{
    margin-block-start: 1em;
    @include display-flex(row, center, center);
  }
  button{
    min-width: 10rem;
    margin: 0 0.5em;
  }
  .delete{
    @include dangerous-action;
  }
</style>
