import { readFile } from 'fs/promises';
import { readdirSync } from 'fs';
import { join } from 'path';
import formatTime from 'pretty-time';
import formatSize from 'pretty-bytes';
import minimist from 'minimist';

const args = minimist(process.argv.slice(2));
const resultsDir = args.results;
if (!resultsDir) throw new Error('Please pass --results');

const results = await Promise.all(
  readdirSync(resultsDir)
    .filter((name) => name.endsWith('.json'))
    .map(async (name) => {
      const text = await readFile(join(resultsDir, name), 'utf-8');
      return JSON.parse(text);
    })
);

console.table(
  results
    .slice()
    .sort((a, b) => a.mean - b.mean)
    .map(({ name, command, version, mean }) => ({
      name,
      command,
      version,
      mean: formatTime(Math.floor(mean * 1_000_000_000), undefined, 5),
    }))
);

console.table(
  results
    .slice()
    .sort((a, b) => a.max_rss - b.max_rss)
    .map(({ name, command, version, max_rss }) => ({
      name,
      command,
      version,
      max_rss: formatSize(max_rss, { minimumFractionDigits: 7 }),
    }))
);
