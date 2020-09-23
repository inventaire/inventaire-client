let wrap;
const Ajax = function(verb, hasBody){
  let ajax;
  return ajax = function(url, body){

    const options = {
      type: verb,
      url
    };

    if (hasBody) {
      options.data = JSON.stringify(body);
      // Do not set content type on cross origin requests as it triggers preflight checks
      // cf https://stackoverflow.com/a/12320736/3324977
      if (url[0] === '/') { options.headers = { 'content-type': 'application/json' }; }
    }

    return wrap($.ajax(options), options)
    .then(parseJson);
  };
};

const preq = {
  get: Ajax('GET', false, true),
  post: Ajax('POST', true),
  put: Ajax('PUT', true),
  delete: Ajax('DELETE', false)
};

const requestAssets = require('./request_assets');

export default _.extend(preq, requestAssets,

(preq.wrap = (wrap = (jqPromise, context) => new Promise((resolve, reject) => jqPromise
.then(resolve)
.fail(err => reject(rewriteJqueryError(err, context))))))
);

var parseJson = function(res){
  if (_.isString(res) && (res[0] === '{')) { return JSON.parse(res);
  } else { return res; }
};

var rewriteJqueryError = function(err, context){
  let message;
  const { status:statusCode, statusText, responseText, responseJSON } = err;
  const { url, type:verb } = context;
  if (statusCode >= 400) {
    const messageWithContext = `${statusCode}: ${statusText} - ${responseText} - ${url}`;
    // We need a clean message in case this is to be displayed as an alert
    message = responseJSON?.status_verbose || messageWithContext;
  } else if (statusCode === 0) {
    app.execute('flash:message:show:network:error');
    message = 'network error';
  } else {
    // cf http://stackoverflow.com/a/6186905
    // Known case: request blocked by CORS headers
    message = `\
parsing error: ${verb} ${url}
got statusCode ${statusCode} but invalid JSON: ${responseText} / ${responseJSON}\
`;
  }

  const error = new Error(message);
  return _.extend(error, { statusCode, statusText, responseText, responseJSON, context });
};
