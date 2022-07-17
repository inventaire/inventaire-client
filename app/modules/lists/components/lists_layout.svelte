<script>
  import { I18n } from '#user/lib/i18n'
  export let id
</script>
<div class="header">
  <p>{I18n('list')}</p>
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

 .header{
   @include display-flex(row, center, center);
   display: flex;
   margin: 1em 0;
   width: 100%;
 }
 .list-id{
 	@include display-flex(column, center);
 	font-size: small;
 }
</style>
