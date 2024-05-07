<script lang="ts">
  import { isNonEmptyPlainObject } from '#app/lib/boolean_tests'
  import EntityImage from '#entities/components/entity_image.svelte'
  import AuthorsInfo from '#entities/components/layouts/authors_info.svelte'
  import EntityTitle from '#entities/components/layouts/entity_title.svelte'
  import Infobox from '#entities/components/layouts/infobox.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import { getAuthorWorksWithImagesAndCoauthors } from '#entities/components/lib/deduplicate_helpers.ts'
  import WorkSubEntity from '#entities/components/work_sub_entity.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { sortMatchedLabelsEntities, hasMatchedLabel } from '#tasks/components/lib/tasks_helpers.ts'
  import { I18n, i18n } from '#user/lib/i18n'

  export let entity
  export let error = null
  export let matchedTitles
  const hasLinkTitle = true
  let subEntities

  const waitingForSubEntities = getAuthorWorksWithImagesAndCoauthors(entity)
    .then(entities => {
      subEntities = sortMatchedLabelsEntities(entities, matchedTitles)
    })
    .catch(err => error = err)

  $: claims = entity.claims
</script>

{#if entity}
  <div class="task-entity">
    <div class="title-row">
      <div class="entity-title-wrapper">
        <EntityTitle
          {entity}
          {hasLinkTitle}
          sourceLogo={true}
        />
      </div>
      {#if isNonEmptyPlainObject(entity.image)}
        <div class="entity-image">
          <EntityImage
            {entity}
            size={96}
            noImageCredits={true}
          />
        </div>
      {/if}
    </div>
    {#if entity.type === 'work'}
      <AuthorsInfo {claims} />
    {/if}
    <div class="entity-section">
      <div class="infobox-wrapper">
        <Infobox
          {claims}
          entityType={entity.type}
        />
      </div>
      <div class="summary-wrapper">
        <Summary {entity} />
      </div>
    </div>
    {#if entity.type === 'human'}
      <div class="sub-entities-section">
        {#await waitingForSubEntities}
          <p class="loading">{i18n('Loading works...')}<Spinner /></p>
        {:then}
          <div class="header">
            <h3>{I18n('works')}</h3>
            <span class="count">{subEntities.length}</span>
          </div>
          <ul>
            {#each subEntities as subEntity (subEntity.uri)}
              <li
                class="sub-entity"
                class:has-matched-label={hasMatchedLabel(subEntity, matchedTitles)}
                title={hasMatchedLabel(subEntity, matchedTitles) ? I18n('Matched title') : null}
              >
                <WorkSubEntity entity={subEntity} />
              </li>
            {/each}
          </ul>
        {/await}
      </div>
    {/if}
  </div>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .task-entity{
    padding: 0 1em;
  }
  .entity-section{
    @include display-flex(row, flex-start, flex-start);
  }
  .title-row{
    @include display-flex(row, flex-start, space-between);
  }
  .infobox-wrapper, .summary-wrapper{
    flex: 1 0 0;
  }
  .summary-wrapper{
    margin-inline-start: 0.3em;
  }
  .header{
    margin-block-start: 0.5em;
    @include display-flex(row, center, center);
  }
  h3{
    font-size: 1.2em;
    @include sans-serif;
  }
  .count{
    background-color: $off-white;
    @include radius;
    text-align: center;
    padding: 0 0.3em;
    font-size: 1rem;
    margin: 0 0.5em;
  }
  .sub-entity{
    @include display-flex(row, flex-start, flex-start);
    margin: 0.3em;
    padding: 0.5em;
    background-color: $off-white;
  }
  .has-matched-label{
    border: 2px solid $lighten-primary-color;
  }
</style>
