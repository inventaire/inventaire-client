<script>
  import { I18n } from '#user/lib/i18n'
  export let inputName
  export let type
  const options = {
    work: {
      label: 'title',
      placeholder: 'must have book title'
    },
    author: {
      label: 'authors',
    }
  }
</script>
<span class="editorRow">
  <span class="label">{I18n(options[type].label)}:</span>
  <input
    on:click|stopPropagation
    type="text"
    class="customInput"
    bind:value={inputName}
    placeholder={I18n(options[type].placeholder)}>
</span>
<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .editorRow{
    @include display-flex(row, center);
  }
  .label{
    display: inline;
    color: $grey;
    font-size: 90%;
    margin-right: 0.5em;
  }
  .customInput{
    margin-bottom: 0;
    width: 100%;
  }
</style>
