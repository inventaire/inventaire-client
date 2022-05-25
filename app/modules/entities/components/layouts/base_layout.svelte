<script>
  import EditDataActions from './edit_data_actions.svelte'
  import EntityHeader from '../entity_header.svelte'

  export let entity
  export let standalone
</script>

<div class="layout">
  <div class="header">
    <EntityHeader {entity} {standalone}/>
    <EditDataActions {entity} />
  </div>
  <div class="entity-wrapper">
    <slot name="entity" />
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  :global(.entity-layout){
    width:100%;
  }
  .layout{
    @include display-flex(column, stretch, center);
    margin: 0 auto;
    max-width: 70em;
    padding: 0 1em;
    background-color: white;
  }
  .header{
    position: relative;
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
    .header{
      @include display-flex(row, center, space-between);
      padding-bottom: 1em;
    }
    .entity-wrapper{
      @include display-flex(column, flex-start);
    }
  }
</style>
