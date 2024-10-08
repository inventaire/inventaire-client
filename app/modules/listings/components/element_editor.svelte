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
      const updatedElement = await updateElement({ id: element._id, comment })
      dispatch('editorDone')
      element = updatedElement
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
<div class="buttons-wrapper">
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
  <button
    class="remove-button dark-grey"
    on:click={() => dispatch('removeElement', element)}
  >
    {@html icon('trash')}
    <span>{I18n('remove')}</span>
  </button>
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
    margin-block-start: 1em;
  }
  .buttons-wrapper{
    margin-block-start: 1em;
    @include display-flex(row, center, space-between);
  }
  button{
    min-width: 10rem;
    margin: 0 0.5em;
  }
  .remove-button{
    @include display-flex(row, flex-end, flex-end);
    float: inline-end;
    margin: 1em 0;
    padding: 0.4em 0.6em;
    @include shy(0.9);
    @include display-flex(row, center, center);
    :global(.fa){
      font-size: 1.1em;
    }
    &:hover, &:focus{
      border-radius: $global-radius;
      background-color: $danger-color;
      color: white;
    }
  }
  /* Very small screens */
  @media screen and (max-width: $very-small-screen){
    .buttons-wrapper{
      @include display-flex(column, center);
    }
  }
</style>
