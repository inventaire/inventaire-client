// Adding assets by creating new assets node in the DOM,
// rather than by doing something like $('head').append("<style>#{cssText}</style")
// as recommanded by http://deano.me/2012/09/jquery-load-css-with-ajax-all-browsers
// Allows to not rely on the CSP 'unsafe-inline'
// Inspired by: https://jeremenichelli.github.io/2016/04/patterns-for-a-promise-based-initialization/

const requestAsset = (type, url) => new Promise(function(resolve, reject){
  let node;
  if (type === 'css') {
    node = document.createElement('link');
    node.type = 'text/css';
    node.rel = 'stylesheet';
    node.href = url;
  } else {
    node = document.createElement('script');
    node.src = url;
    node.async = true;
  }

  node.onload = resolve;
  node.onerror = normalizeError(reject, url);

  return document.head.appendChild(node);
});

export default {
  getCss: requestAsset.bind(null, 'css'),
  getScript: requestAsset.bind(null, 'js')
};

var normalizeError = (reject, url) => (function(errEvent) {
  const err = new Error('request asset failed');
  err.context = { url };
  return reject(err);
});
