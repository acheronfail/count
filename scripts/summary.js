import { readFile } from 'fs/promises';
import { readdirSync } from 'fs';
import { join } from 'path';
import formatTime from 'pretty-time';
import formatSize from 'pretty-bytes';

const resultsDir = './results';
const results = await Promise.all(
  readdirSync(resultsDir)
    .filter((name) => name.endsWith('.json'))
    .map(async (name) => {
      const text = await readFile(join(resultsDir, name), 'utf-8');
      const json = JSON.parse(text);

      return {
        name: [name, json.command].join(' :: '),
        ...json,
      };
    })
);

console.table(
  results
    .slice()
    .sort((a, b) => a.mean - b.mean)
    .map(({ name, mean }) => ({
      name,
      mean: formatTime(Math.floor(mean * 1_000_000_000), undefined, 5),
    }))
);

console.table(
  results
    .slice()
    .sort((a, b) => a.max_rss - b.max_rss)
    .map(({ name, max_rss }) => ({ name, max_rss: formatSize(max_rss, { minimumFractionDigits: 7 }) }))
);
