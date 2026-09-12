#!/usr/bin/env node
const { readFileSync } = require('node:fs');
const file = process.argv[2];
if (!file) throw new Error('Usage: validate-update.mjs update.json');
const x = JSON.parse(readFileSync(file, 'utf8'));
const required = ['schema_version','module','version','build','channel','commit','release_date','changelog','compatibility','artifacts','migration_requirements','security_update','breaking_change'];
for (const key of required) if (!(key in x)) throw new Error(`missing ${key}`);
if (x.schema_version !== 1 || !/^[a-z0-9_]+$/.test(x.module)) throw new Error('invalid schema or module');
if (!/^\d+\.\d+\.\d+([-.][0-9A-Za-z.]+)?$/.test(x.version) || !Number.isInteger(x.build) || x.build < 1) throw new Error('invalid version/build');
const c=x.compatibility;
if (!Number.isInteger(c.android_api_min) || !Number.isInteger(c.android_api_max) || c.android_api_min > c.android_api_max || !Array.isArray(c.abis) || !c.abis.length) throw new Error('invalid compatibility');
if (!Array.isArray(x.artifacts) || !x.artifacts.length) throw new Error('missing artifacts');
for (const a of x.artifacts) {
  if (typeof a.name !== 'string' || !a.name.endsWith('.zip')) throw new Error('invalid artifact name');
  if (a.url !== null && typeof a.url !== 'string') throw new Error('invalid artifact URL');
  if (a.sha256 !== null && !/^[a-f0-9]{64}$/.test(a.sha256)) throw new Error('invalid artifact hash');
}
console.log(`valid update metadata: ${x.module} ${x.version}+${x.build}`);
