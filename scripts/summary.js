import { readFile, writeFile } from 'fs/promises';
import { readdirSync } from 'fs';
import { join } from 'path';
import { markdownTable } from 'markdown-table';
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

await writeFile(
  'summary.md',
  `
${markdownTable(
  [
    ['name', 'command', 'version'],
    ...results
      .slice()
      .sort((a, b) => a.name.localeCompare(b.name))
      .map(({ name, command, version }) => [name, command, version]),
  ],
  {
    align: ['l', 'l', 'l'],
  }
)}

${markdownTable(
  [
    ['name', 'mean'],
    ...results
      .slice()
      .sort((a, b) => a.mean - b.mean)
      .map(({ name, mean }) => [name, formatTime(Math.floor(mean * 1_000_000_000), undefined, 5)]),
  ],
  {
    align: ['l', 'r'],
  }
)}

${markdownTable(
  [
    ['name', 'max_rss'],
    ...results
      .slice()
      .sort((a, b) => a.max_rss - b.max_rss)
      .map(({ name, max_rss }) => [name, formatSize(max_rss, { minimumFractionDigits: 7 })]),
  ],
  {
    align: ['l', 'r'],
  }
)}
`.trim()
);
