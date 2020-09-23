import { folder } from './config';
import { exec } from 'child_process';
import { grey, green } from 'chalk';
import fs from 'fs';
const ls = dir => console.log(fs.readdirSync(dir));
const cp = (orignal, copy) => fs.createReadStream(orignal)
.pipe(fs.createWriteStream(copy));

const { stderr } = process;

export default {
  rmFiles() {
    exec(`rm ${folder}/*`).stderr.pipe(stderr);
    return console.log(grey('removed old files'));
  },
  gzipFiles() {
    exec(`for f in ${folder}/*; do gzip --best < $f > $f.gz; done`).stderr.pipe(stderr);
    return console.log(green('gzipping files'));
  },
  generateMainSitemap() {
    cp(`${__dirname}/main.xml`, `${folder}/main.xml`);
    return console.log(green('copied main.xml'));
  },

  ls,
  cp
};
