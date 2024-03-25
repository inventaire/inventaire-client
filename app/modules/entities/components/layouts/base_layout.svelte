<script>
  import EntityLayoutActionsMenu from '#entities/components/layouts/entity_layout_actions_menu.svelte'
  import { entityTypeNameBySingularType } from '#entities/lib/types/entities_types'
  import Flash from '#lib/components/flash.svelte'
  import { I18n } from '#user/lib/i18n'
  import EmbeddedWelcome from '#welcome/components/embedded_welcome.svelte'
  import { buildAltUri } from '../lib/entities.ts'

  export let entity
  export let flash = null
  export let showEntityEditButtons = true
  export let typeLabel = entity.type

  const { uri, _id } = entity

  const altUri = buildAltUri(uri, _id)
</script>

<div class="layout">
  <div class="header-wrapper">
    <div class="header">
      <h2 class="typeLabel">{I18n(entityTypeNameBySingularType[typeLabel])}</h2>
    </div>
    <EntityLayoutActionsMenu
      bind:entity
      {showEntityEditButtons}
    />
  </div>
  <div class="entity-wrapper">
    <slot name="entity" />
  </div>
  <Flash state={flash} />
  <div class="entity-data-wrapper">
    <p class="uri">
      {I18n(typeLabel)}
      - {uri}
      {#if altUri}
        - {altUri}
      {/if}
    </p>
  </div>
</div>

<EmbeddedWelcome />

<style lang="scss">
  @import "#general/scss/utils";
  .layout{
    @include display-flex(column, stretch, center);
    margin: 0 auto;
    max-inline-size: 84em;
    background-color: white;
  }
  .typeLabel{
    color: $grey;
    font-size: 1.1rem;
    @include sans-serif;
  }
  .header-wrapper{
    display: flex;
    margin: 1em 0;
  }
  .header{
    @include display-flex(row, center, center);
    inline-size: 100%;
  }
  .entity-wrapper{
    @include display-flex(column, flex-start);
  }
  .entity-data-wrapper{
    @include display-flex(column, center);
  }
  /* Large screens */
  @media screen and (min-width: $small-screen){
    .layout{
      padding: 0 1em;
    }
    .header-wrapper{
      margin-inline-start: 1.2em;
    }
  }
  /* Small screens */
  @media screen and (max-width: $small-screen){
    .layout{
      padding: 0 0.5em;
    }
    .header-wrapper{
      @include display-flex(row, center, space-between);
    }
    .entity-wrapper{
      @include display-flex(column, flex-start);
    }
  }
  /* Very Small screens */
  @media screen and (max-width: $very-small-screen){
    .layout{
      padding: 0 0.5em;
    }
  }
</style>
