<script>
  import { isNonEmptyPlainObject } from '#lib/boolean_tests'
  import { omitClaims } from '#entities/components/lib/work_helpers'
  import { authorsProps, relativeEntitiesListsProps } from '#entities/components/lib/claims_helpers'
  import { getAuthorWorksWithImagesAndCoauthors } from '#entities/components/lib/deduplicate_helpers.js'
  import { I18n, i18n } from '#user/lib/i18n'
  import { intersection } from 'underscore'
  import Spinner from '#general/components/spinner.svelte'
  import Infobox from '#entities/components/layouts/infobox.svelte'
  import EntityTitle from '#entities/components/layouts/entity_title.svelte'
  import EntityImage from '#entities/components/entity_image.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import TaskSubEntity from '#entities/components/task_sub_entity.svelte'

  export let entity, error, matchedTitles
  let standalone = false
  let subEntities

  const waitingForSubEntities = getAuthorWorksWithImagesAndCoauthors(entity)
    .then(res => {
      const matchedLabelsFirstEntities = res.sort((a, b) => hasMatchedLabel(a) < hasMatchedLabel(b) ? 1 : -1)
      subEntities = matchedLabelsFirstEntities
    })
    .catch(err => error = err)

  function hasMatchedLabel (entity) {
    const entityLabels = Object.values(entity.labels)
    const matchedLabels = intersection(matchedTitles, entityLabels)
    return matchedLabels.length > 0
  }

  $: claims = omitClaims(entity.claims, [ authorsProps, relativeEntitiesListsProps ])
</script>

{#if entity}
  <div class="task-entity">
    <div class="title-row">
      <div class="entity-title-wrapper">
        <EntityTitle
          {entity}
          {standalone}
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
              class:has-matched-label={hasMatchedLabel(subEntity)}
              title={hasMatchedLabel(subEntity) ? I18n('Matched title') : null}
            >
              <TaskSubEntity entity={subEntity} />
            </li>
          {/each}
        </ul>
      {/await}
    </div>
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
    margin-left: 0.3em;
  }
  .header{
    margin-top: 0.5em;
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
    padding: 0 0.5em;
    background-color: $off-white;
  }
  .has-matched-label{
    border: 2px solid $lighten-primary-color;
  }
</style>
