<script>
  import { I18n } from '#user/lib/i18n'
  import ListSelections from './list_selections.svelte'
  import ListInfoBox from '#modules/lists/components/list_info_box.svelte'
  export let list

  let { _id, creator, selections } = list

  let isEditable = creator === app.user.id
</script>

<div class="list-layout">
  <ListInfoBox {list} />
  <ListSelections
    bind:selections
    listId={_id}
    {isEditable}
  />
</div>

<div class="footer">
  <p class="list-id">
    {I18n('list')}
      -
    {_id}
  </p>
</div>

<style lang="scss">
  @import '#general/scss/utils';
 .list-layout{
   @include display-flex(column, center);
 }
 .list-id{
 	@include display-flex(column, center);
 	font-size: small;
 }
</style>
