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
<span class="editor-row">
  <span class="label">{I18n(options[type].label)}:</span>
  <input
    on:click|stopPropagation
    type="text"
    class="custom-input"
    bind:value={inputName}
    placeholder={I18n(options[type].placeholder)}>
</span>
<style lang="scss">
  @import '#modules/general/scss/utils';
  .label{
    display: inline;
    color: $grey;
    font-size: 90%;
    margin-right: 0.5em;
  }
  .custom-input{
    margin: 0 0 0.5em 0;
  }
  /*Large screens*/
  @media screen and (min-width: 800px) {
    .editor-row{
      @include display-flex(row, center);
    }
    .custom-input{
      margin: 0.5em 0;
    }
  }
</style>
