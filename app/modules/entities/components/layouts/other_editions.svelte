<script>
  import { I18n } from '#user/lib/i18n'
  import Link from '#lib/components/link.svelte'
  import { isNonEmptyPlainObject, isNonEmptyArray } from '#lib/boolean_tests'
  import EntityImage from '../entity_image.svelte'
  import { isOtherEditionWithCover } from '#entities/components/lib/edition_layout_helpers'

  export let currentEdition, work

  const { editions } = work
  const { uri: workUri, label: workLabel } = work
  const allOtherEditions = editions.filter(isOtherEditionWithCover(currentEdition))
  const otherEditions = allOtherEditions.splice(0, 4)
</script>

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

<style lang="scss">
  @import "#general/scss/utils";
  .other-work-editions{
    @include display-flex(column, center, flex-end);
    @include radius;
    max-inline-size: 20em;
    padding-block-start: 1em;
    margin: 0.5em;
    background-color: $off-white;
    :global(.work-button){
      margin: 1em;
      inline-size: 15em;
      padding: 0.5em;
      text-align: center;
      text-decoration: none;
    }
  }
  .entities-list{
    @include display-flex(row, center, center);
  }
</style>
