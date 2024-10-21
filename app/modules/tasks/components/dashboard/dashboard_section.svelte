<script>
  import Link from '#app/lib/components/link.svelte'
  import { pluralize } from '#entities/lib/types/entities_types'
  import { I18n } from '#user/lib/i18n'

  export let entitiesType, tasksCount

  const noTask = tasksCount === 0
  const pluralizedEntitiesType = pluralize(entitiesType)
</script>
<div class="section-wrapper">
  <div class="section-title">
    {I18n(pluralizedEntitiesType)}
    <span
      class="counter"
      class:no-task-counter={noTask}
    >
      {tasksCount}
    </span>
  </div>
  {#if tasksCount > 0}
    <Link
      url="/tasks/{entitiesType}"
      text={I18n('resolve tasks')}
      tinyButton={true}
    />
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .section-wrapper{
    @include display-flex(column, center);
    background-color: $light-grey;
    margin: 0.5em;
    padding: 1em;
    min-width: 10em;
    min-height: 6em;
  }
  .section-title{
    font-size: 1.1rem;
    margin-block-end: 1em;
  }
  .counter{
    font-size: 1rem;
    font-weight: bold;
    color: $grey;
    padding: 0 0.3em;
    margin-inline-start: 0.5em;
    background-color: $yellow;
    @include radius;
  }
  .no-task-counter{
    background-color: white;
  }

</style>
