<script>
  import EditDataActions from './edit_data_actions.svelte'
  import EntityHeader from '../entity_header.svelte'
  import preq from '#lib/preq'

  export let entity
  export let standalone

  const refreshEntity = async () => {
    const { entities } = await preq.get(app.API.entities.getByUris(entity.uri, true))
    entity = Object.values(entities)[0]
  }
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
    position: relative;
    @include display-flex(row, center, space-between);
  }
  .header{
    @include display-flex(row, flex-end, flex-end);
    width: 10%;
  }
  .entity-wrapper{
    @include display-flex(column, flex-start);
    margin-bottom: 2em;
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
