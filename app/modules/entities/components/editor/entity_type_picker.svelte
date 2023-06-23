<script>
  import { I18n } from '#user/lib/i18n'
  import { entityTypeNameBySingularType } from '#entities/lib/types/entities_types'
  import { locallyCreatableEntitiesTypes } from '#entities/lib/editor/properties_per_type'

  export let selectedType
</script>

<div class="type-picker" role="listbox">
  {#each locallyCreatableEntitiesTypes as type}
    <div
      role="option"
      aria-selected={selectedType === type}
    >
      <button
        on:click={() => selectedType = type}
        class:selected={selectedType === type}
      >
        {I18n(entityTypeNameBySingularType[type])}
      </button>
    </div>
  {/each}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .type-picker{
    flex: 1;
    text-align: center;
    @include display-flex(row, center, center, wrap);
    margin: 0.5em 0.5em 2em;
    white-space: nowrap;
  }
  [role="option"]{
    flex: 1 0 6em;
    max-inline-size: 10em;
    margin: 0.1em;
  }
  button{
    @include big-button($grey);
    padding: 1em;
    inline-size: 100%;
    &.selected{
      @include bg-hover(white, 0%);
      color: $dark-grey;
    }
  }
</style>
