<script lang="ts">
  export let value
</script>

<p class="fixed-value">{value}</p>

<style lang="scss">
  @use "#general/scss/utils";
  .fixed-value{
    flex: 1;
  }
</style>
