<script>
  import { I18n } from 'modules/user/lib/i18n'
  import LabelsEditor from './labels_editor.svelte'
  import ClaimsEditor from './claims_editor.svelte'

  export let entity

  console.log('entity', entity)
</script>

<div class="entity-edit">
  <h2>{I18n(entity.type)}</h2>
  <LabelsEditor {entity} />
  <ClaimsEditor {entity} />
</div>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .entity-edit{
    @include display-flex(column, center, center);
    max-width: 50em;
    margin: 0 auto;
  }
  h2{
    text-align: center;
  }
</style>
