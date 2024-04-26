module.exports = {
  extends: '../.eslintrc.cjs',
  plugins: [
    'node-import',
  ],
  rules: {
    'node-import/prefer-node-protocol': 2,
  },
}
