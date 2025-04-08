<script lang="ts">
  export let externalShelf
</script>
<label>
  <input type="checkbox" bind:checked={externalShelf.checked} />
  {externalShelf.name}
</label>
<style lang="scss">
  @use "#general/scss/utils";
  input{
    margin-inline-end: 0.5em;
  }
  label{
    font-size: 1rem;
  }
</style>
