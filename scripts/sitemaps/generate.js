#!/usr/bin/env nodeimport generateSitemaps from './generate_sitemaps';
import generateIndex from './generate_index';
import { rmFiles, gzipFiles, generateMainSitemap } from './files_commands';
import { red } from 'chalk';

rmFiles();

generateMainSitemap();

generateSitemaps()
.then(generateIndex)
.then(gzipFiles)
.catch(err => console.log(red('global err'), err.stack));
