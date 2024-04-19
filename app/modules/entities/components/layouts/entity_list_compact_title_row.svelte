<script lang="ts">
  import { I18n } from '#user/lib/i18n'
</script>
<div class="entity-list-compact">
  <div class="date">
    {I18n('date')}
  </div>

  <div class="title">
    {I18n('title')}
  </div>

  <div class="authors">
    {I18n('authors')}
  </div>
</div>
<style lang="scss">
  @import "#general/scss/utils";
  @import "#entities/scss/entity_list_compact";
  .entity-list-compact{
    font-weight: bold;
    border-block-end: 1px solid #ddd;
    position: sticky;
    inset-block: 0;
  }
</style>
