<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { updateList } from '#lists/lib/lists'
  import autosize from 'autosize'
  import Spinner from '#general/components/spinner.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()

  export let list

  let isValidating, flash
  const { _id } = list
  let { name, description } = list

  const validate = async () => {
    isValidating = true
    return updateList({
      id: _id,
      name,
      description,
    })
    .then(list => dispatch('listUpdated', list))
    .then(closeModal)
    .catch(err => {
      // Prefer to close modal anyway if no info have been updated,
      // since action is most likely motivated by escaping this context,
      // hence close modal.
      if (err.message === 'nothing to update') {
        return closeModal()
      }
      flash = err
    })
    .finally(() => isValidating = false)
  }
  const closeModal = () => app.execute('modal:close')
</script>
<div class="header">
  <h3>{I18n('edit list')}</h3>
</div>
<div class="field">
  <label for={name}>{i18n('name')}</label>
  <input
  	placeholder={i18n('list name')}
  	bind:value={name}
  />
</div>
<div class="field">
  <label for={description}>{i18n('description')}</label>
	<textarea
		type="text"
    bind:value={description}
    use:autosize
	/>
</div>
<!-- todo: visibility after finer privacy setting is merged -->
<div class="buttons">
  <button
  	class="validate button success-button"
  	title={I18n('validate')}
  	on:click={validate}
  >
    {@html icon('check')}
    {I18n('validate')}
    {#if isValidating}
    	<p class="loading">
    		<Spinner/>
    	</p>
    {/if}
  </button>
</div>
<Flash bind:state={flash}/>

<style lang="scss">
	@import '#general/scss/utils';
	.header{
	 @include display-flex(column, center);
	 display: flex;
	 width: 100%;
	}
	.field{
		@include display-flex(column, flex-start, center);
	}
	.buttons{
		@include display-flex(column, center);
	}
</style>
