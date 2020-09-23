import fs from 'fs';
import { promisify } from 'util';
const writeFile = promisify(fs.writeFile);
const { grey, red, green } = require('chalk');

export default function(path, content){
  console.log(grey('writting sitemap'), path);
  return writeFile(path, content, function(err, res){
    if (err != null) { return console.log(red('err'), err);
    } else { return console.log(green('done!')); }
  });
};
