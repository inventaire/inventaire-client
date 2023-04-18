<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import Spinner from '#general/components/spinner.svelte'
  import Link from '#lib/components/link.svelte'
  import { isNonEmptyPlainObject, isNonEmptyArray } from '#lib/boolean_tests'
  import EntityImage from '../entity_image.svelte'
  import { getSubEntities } from '../lib/entities'

  export let currentEdition, work

  let editions = []
  let otherEditions
  const { uri: workUri, label: workLabel } = work
  const getEditionsFromWork = async () => {
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
    <p class="loading">{i18n('Looking for editions…')}
      <Spinner />
    </p>
  </div>
{:then}
  {#if isNonEmptyArray(otherEditions)}
    <li class="other-work-editions">
      <div class="entities-list">
        {#each otherEditions as entity (entity.uri)}
          {#if isNonEmptyPlainObject(entity.image)}
            <EntityImage
              {entity}
              withLink="true"
              maxHeight="6em"
              size={128}
            />
          {/if}
        {/each}
      </div>
      <Link
        url={`/entity/${workUri}`}
        classNames="work-button"
        html={I18n('see_all_work_editions', { label: workLabel })}
        grey={true}
        tinyButton={true}
      />
    </li>
  {/if}
{/await}

<style lang="scss">
  @import "#general/scss/utils";
  .other-work-editions{
    @include display-flex(column, center, flex-end);
    @include radius;
    max-width: 20em;
    padding-top: 1em;
    margin: 0.5em;
    background-color: $off-white;
    :global(.work-button){
      margin: 1em;
      width: 15em;
      padding: 0.5em;
      text-align: center;
      text-decoration: none;
    }
  }
  .entities-list{
    @include display-flex(row, center, center);
  }
</style>
