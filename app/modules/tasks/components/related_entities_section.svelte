<script lang="ts">
  import EntityListRow from '#entities/components/layouts/entity_list_row.svelte'
  import SectionLabel from '#entities/components/layouts/section_label.svelte'
  import { hasMatchedLabel } from '#tasks/components/lib/tasks_helpers'
  import { I18n } from '#user/lib/i18n'

  export let section, matchedTitles

  const { entities: subEntities, label } = section
// Todo
// about collections tasks : make sure no publishers subentities are displayed (or remove it from infobox)
</script>

{#if subEntities.length > 0}
  <ul>
    <SectionLabel
      {label}
      entitiesLength={subEntities.length}
    />
    {#each subEntities as subEntity (subEntity.uri)}
      <li
        class="related-entity"
        class:has-matched-label={hasMatchedLabel(subEntity, matchedTitles)}
        title={hasMatchedLabel(subEntity, matchedTitles) ? I18n('Matched title') : null}
      >
        <EntityListRow entity={subEntity} />
      </li>
    {/each}
  </ul>
{/if}
<style lang="scss">
  @import "#general/scss/utils";
  ul{
    margin-block-start: 1em;
  }
  .related-entity{
    @include display-flex(row, flex-start, flex-start);
    margin: 0.3em;
    padding: 0.5em;
    background-color: $off-white;
  }
  .has-matched-label{
    border: 2px solid $lighten-primary-color;
  }
</style>
