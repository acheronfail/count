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

const wrap = (s) => `\`${s}\``;

await writeFile(
  'summary.md',
  `
<table>
<tr>
  <th>Execution time</th>
  <th>Binary size</th>
  <th>Max Memory Usage*</th>
</tr>
<tr>
<td>

${markdownTable(
  [
    ['position', 'name', 'mean'],
    ...results
      .slice()
      .sort((a, b) => a.mean - b.mean)
      .map(({ name, mean }, i) => [i + 1, wrap(name), formatTime(Math.floor(mean * 1_000_000_000), undefined, 5)]),
  ],
  {
    align: ['c', 'l', 'r'],
  }
)}

</td>
<td>

${markdownTable(
  [
    ['position', 'name', 'size'],
    ...results
      .slice()
      .sort((a, b) => a.name.localeCompare(b.name))
      .sort((a, b) => (a.size ?? Infinity) - (b.size ?? Infinity))
      .map(({ name, size }, i) => [i + 1, wrap(name), size ? formatSize(size, { minimumFractionDigits: 7 }) : '-']),
  ],
  {
    align: ['c', 'l', 'r'],
  }
)}

</td>
<td>

${markdownTable(
  [
    ['#', 'name', 'max_rss'],
    ...results
      .slice()
      .sort((a, b) => a.max_rss - b.max_rss)
      .map(({ name, max_rss }, i) => [i + 1, wrap(name), formatSize(max_rss, { minimumFractionDigits: 7 })]),
  ],
  {
    align: ['l', 'l', 'r'],
  }
)}

</td>
</tr>
</table>

> \`*\`: Getting the \`max_rss\` isn't 100% reliable for very small binary sizes
> this appears to be [a limitation of the linux kernel](https://github.com/acheronfail/timeRS/blob/master/LIMITATIONS.md).

${markdownTable(
  [
    ['name', 'command', 'version'],
    ...results
      .slice()
      .sort((a, b) => a.name.localeCompare(b.name))
      .flatMap(({ name, command, version }) =>
        version
          .split('\n')
          .map((versionLine, i) => [i == 0 ? wrap(name) : '', i == 0 ? wrap(command) : '', versionLine])
      ),
  ],
  {
    align: ['l', 'r', 'l'],
  }
)}

`.trim()
);
