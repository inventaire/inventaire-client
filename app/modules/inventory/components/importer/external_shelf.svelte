<script>
  export let externalShelf
</script>
<label>
  <input type="checkbox" bind:checked={externalShelf.checked}>
  {externalShelf.name}
</label>
<style lang="scss">
  @import '#general/scss/utils';
  input{
    margin-right: 0.5em;
  }
  label{
    font-size: 1rem;
  }
</style>
