<script>
  import { I18n } from '#user/lib/i18n'
  import { buildAltUri } from '../lib/entities'
  import EditDataActions from './edit_data_actions.svelte'
  import EntityHeader from '../entity_header.svelte'
  import preq from '#lib/preq'

  export let entity
  export let standalone

  const { uri, _id, type } = entity

  const refreshEntity = async () => {
    const { entities } = await preq.get(app.API.entities.getByUris(uri, true))
    entity = Object.values(entities)[0]
  }

  const altUri = buildAltUri(uri, _id)
</script>

<div class="layout">
  <div class="header-wrapper">
    <div class="header-title">
      <EntityHeader {entity} {standalone}/>
    </div>
    <div class="header">
      <EditDataActions
        {entity}
        on:refreshEntity={refreshEntity}
      />
    </div>
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
  .header-title{
    @include display-flex(row, center);
    width: 100%;
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
  /*Very Small screens*/
  @media screen and (max-width: $very-small-screen) {
    .layout{
      padding: 0;
    }
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .header-wrapper{
      @include display-flex(row, center, space-between);
      padding-bottom: 1em;
    }
    .entity-wrapper{
      @include display-flex(column, flex-start);
    }
  }
</style>
