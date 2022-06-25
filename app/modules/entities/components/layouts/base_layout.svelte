<script>
  import { I18n } from '#user/lib/i18n'
  import { buildAltUri } from '../lib/entities'
  import EditDataActions from './edit_data_actions.svelte'
  import preq from '#lib/preq'

  export let entity

  const { uri, _id, type } = entity

  const refreshEntity = async () => {
    const { entities } = await preq.get(app.API.entities.getByUris(uri, true))
    entity = Object.values(entities)[0]
  }

  const altUri = buildAltUri(uri, _id)
</script>

<div class="layout">
  <div class="header-wrapper">
    <div class="header">
      <p class="type">{I18n(type)}</p>
    </div>
    <EditDataActions
      {entity}
      on:refreshEntity={refreshEntity}
    />
  </div>
  <div class="entity-wrapper">
    <slot name="entity" />
  </div>
  <div class="entity-data-wrapper">
    <p class="uri">
      {I18n(type)}
      - {uri}
      {#if altUri}
         - {altUri}
      {/if}
    </p>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .layout{
    @include display-flex(column, stretch, center);
    margin: 0 auto;
    max-width: 70em;
    padding: 0 1em;
    background-color: white;
  }
  .type{
    color: $grey;
    font-size: 1rem;
  }
  .header-wrapper{
    display: flex;
    margin: 1em 0;
  }
  .header{
    @include display-flex(row, center, center);
    width: 100%;
  }
  .entity-wrapper{
    @include display-flex(column, flex-start);
    margin-bottom: 2em;
  }
  .entity-data-wrapper{
    @include display-flex(column, center);
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .header-wrapper{
      margin-left: 1.2em;
    }
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .header-wrapper{
      @include display-flex(row, center, space-between);
    }
    .entity-wrapper{
      @include display-flex(column, flex-start);
    }
  }
  /*Very Small screens*/
  @media screen and (max-width: $very-small-screen) {
    .layout{
      padding: 0;
    }
  }
</style>
