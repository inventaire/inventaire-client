# Inventaire-client
Libre collaborative resource mapper powered by open-knowledge

[![License](https://img.shields.io/badge/license-AGPL3-blue.svg)](http://www.gnu.org/licenses/agpl-3.0.html)
[![Node](https://img.shields.io/badge/node->=v4-brightgreen.svg)](https://nodejs.org)
[![Code Climate](https://codeclimate.com/github/inventaire/inventaire/badges/gpa.svg)](https://codeclimate.com/github/inventaire/inventaire)<br>
<br>
[![chat](https://img.shields.io/badge/chat-%23inventaire-ffd402.svg)](https://wiki.inventaire.io/wiki/Communication_channels#Chat)
[![wiki](https://img.shields.io/badge/wiki-general-319cc2.svg)](https://wiki.inventaire.io)

This repository tracks [inventaire.io](https://inventaire.io) client-side developments, while the [server-side can be found here](https://codeberg.org/inventaire/inventaire). The server repository gathers the documentation and general issues of the project.

[![inventory screenshot](https://codeberg.org/inventaire/inventaire/assets/1596934/844c04ff-a216-48dc-b3b9-c33a106b8fbe)](https://inventaire.io)

A map of the client assets generated  by this repository can be found at [`/public/dist/bundle_report.html`](https://inventaire.io/public/dist/bundle_report.html).

## Summary

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Stack Map](#stack-map)
- [Install](#install)
- [Development](#development)
- [Prodution](#prodution)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Stack Map
This repo correspond to the the "Client" section in the [stack map](https://inventaire.github.io/stack/)

## Install
```sh
git clone https://codeberg.org/inventaire/inventaire-client
cd inventaire-client
npm install
```

## Development
After having started the [inventaire server](https://codeberg.org/inventaire/inventaire/) on port `3006`
```sh
# start webpack dev server on port 3005 to benefit from hot reloading
npm start

# open http://localhost:3005 in your web browser
```

## Prodution
```sh
npm run build
```

## License
Inventaire is an open-sourced project licensed under [AGPLv3](./LICENSES/AGPL-3.0-only.txt).
