import { readFile } from 'fs/promises';
import { readdirSync } from 'fs';
import { join } from 'path';
import yaml from 'js-yaml';
import formatTime from 'pretty-time';
import formatSize from 'pretty-bytes';

const resultsDir = './results';
const results = await Promise.all(
  readdirSync(resultsDir).map(async (name) => {
    const text = await readFile(join(resultsDir, name), 'utf-8');
    const json = yaml.load(text.replace(/INFO \[timers\] /g, '').replace(/ -$/gm, ' null'));

    const rss_split = json['max_rss'].indexOf(' ');
    return {
      name: [name, json['cmdline']].join(' :: '),
      real: parseInt(json['real'].replace('ns', '')),
      rss: parseInt(json['max_rss'].substring(0, rss_split)),
      rss_fmt: json['max_rss'].substring(rss_split),
    };
  })
);

console.table(
  results
    .slice()
    .sort((a, b) => a.real - b.real)
    .map(({ name, real }) => ({ name, real: formatTime(real) }))
);

console.table(
  results
    .slice()
    .sort((a, b) => a.rss - b.rss)
    .map(({ name, rss }) => ({ name, rss: formatSize(rss, { minimumFractionDigits: 7 }) }))
);
