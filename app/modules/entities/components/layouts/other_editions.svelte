<script>
  import { I18n } from '#user/lib/i18n'
  import Spinner from '#general/components/spinner.svelte'
  import Link from '#lib/components/link.svelte'
  import EntitiesList from './entities_list.svelte'
  import { getSubEntities } from '../lib/entities'
  import { isNonEmptyArray } from '#lib/boolean_tests'

  export let currentEdition, workUri

  let editions = []
  let otherEditions

  const getEditionsFromWork = async () => {
    // TODO: fetch multiple works edition
    editions = await getSubEntities('work', workUri)
    const allOtherEditions = editions.filter(filterEditionWithCover(currentEdition))
    otherEditions = allOtherEditions.splice(0, 4)
  }

  const filterEditionWithCover = currentEdition => edition => {
    return (edition.uri !== currentEdition.uri) && edition.image
  }
</script>

{#await getEditionsFromWork()}
  <div class="loading-wrapper">
    <p class="loading">{I18n('looking for editions...')}
      <Spinner/>
    </p>
  </div>
{:then}
	{#if isNonEmptyArray(otherEditions)}
	  <div class="other-editions">
	    <div class="editions-list-title">
	      <h5>
	        {I18n('other editions')}
	      </h5>
	    </div>
	    <EntitiesList
	      type='editions'
	      entities={otherEditions}
	      compactView={true}
	    />
	    <button class="work-button tiny-button grey">
	      <Link
	        url={`/entity/${workUri}`}
	        text={I18n('see_all_work_editions', { label: currentEdition.label })}
	        light={true}
	        escapeHtml={true}
	      />
	    </button>
	  </div>
	{/if}
{/await}

<style lang="scss">
  @import '#general/scss/utils';
  .other-editions{
    @include display-flex(column, center);
    @include radius;
    max-width: 20em;
    padding: 0.5em;
    background-color: $off-white;
  }
  .work-button{
    margin: 1em;
    width: 15em;
    padding: 0.5em;
  }
</style>
