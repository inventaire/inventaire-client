const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer')

module.exports = new BundleAnalyzerPlugin({
  analyzerMode: 'static',
  reportFilename: 'bundle_report.html',
  generateStatsFile: true,
  statsFilename: 'bundle_stats.json',
  openAnalyzer: false,
})
