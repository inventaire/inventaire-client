<script>
  import ContributionsPeriod from './contributions_period.svelte'
</script>
<div id="activityLayout">
  <ContributionsPeriod title='last day' period=1/>
  <ContributionsPeriod title='last week' period=7/>
  <ContributionsPeriod title='global'/>
</div>
<style lang="scss">
  @import 'app/modules/general/scss/utils';
  #activityLayout{
    display: flex;
    flex-direction: column;
    align-items: center;
  }
</style>
