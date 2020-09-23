import { host } from 'lib/urls';
const absolutePath = function(url){ if (url?.[0] === '/') { return host + url; } else { return url; } };

export default function(key, value, noCompletion){
  if (withTransformers.includes(key)) { return transformers[key](value, noCompletion);
  } else { return value; }
};

var transformers = {
  title(value, noCompletion){
    if (noCompletion) { return value; } else { return `${value} - Inventaire`; }
  },
  url(canonical){ return host + canonical; },
  image(url){
    if (url.match(/\d+x\d+/)) { return absolutePath(url);
    } else { return absolutePath(app.API.img(url)); }
  }
};

var withTransformers = Object.keys(transformers);
