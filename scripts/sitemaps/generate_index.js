import _ from 'lodash';
import writeSitemap from './write_sitemap';
import fs from 'fs';
import { publicPath, folder, index } from './config';
const exclude = [ index ];

export default function() {
  const path = `${folder}/${index}`;
  return writeSitemap(path, generate());
};

var generate = () => wrapIndex(getList().map(buildSitemapNode));

var getList = () => fs.readdirSync(folder)
.filter(file => !exclude.includes(file));

var buildSitemapNode = function(filename){
  const url = `https://inventaire.io/${publicPath}/${filename}`;
  return `<sitemap><loc>${url}</loc></sitemap>`;
};

var wrapIndex = function(sitemapNodes){
  const text = sitemapNodes.join('');
  return `\
<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${text}
</sitemapindex>\
`;
};
