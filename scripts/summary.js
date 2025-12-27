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

const SIZE_T_BINARY = 'binary';
const sizeTypes = new Set([SIZE_T_BINARY]);
const results = await Promise.all(
  readdirSync(resultsDir)
    .filter((name) => name.endsWith('.json'))
    .map(async (name) => {
      const text = await readFile(join(resultsDir, name), 'utf-8');
      const json = JSON.parse(text);

      if ('size' in json) {
        const [bytes, type] = json.size.split('\n');
        json.size = parseInt(bytes);
        json.sizeType = type ?? SIZE_T_BINARY;
        sizeTypes.add(json.sizeType);
      }

      return json;
    })
);

const wrap = (s) => `\`${s}\``;

await writeFile(
  'summary.md',
  `
<table>
<tr>
  <th>Execution time</th>
  <th>Binary size<sup>1</sup></th>
  <th>Max Memory Usage</th>
</tr>
<tr>
<td>

${markdownTable(
  [
    ['#', 'name', 'mean'],
    ...results
      .slice()
      .sort((a, b) => a.mean - b.mean)
      .map(({ name, mean }, i) => [i + 1, wrap(name), formatTime(Math.floor(mean * 1_000_000_000), undefined, 5)]),
  ],
  {
    align: ['l', 'l', 'r'],
  }
)}

</td>
<td>

${[...sizeTypes.values()]
  .map(
    (sizeType) =>
      `**${sizeType}**:\n` +
      markdownTable(
        [
          ['#', 'name', 'size'],
          ...results
            .slice()
            .filter((x) => x.sizeType === sizeType)
            .sort((a, b) => a.name.localeCompare(b.name))
            .sort((a, b) => (a.size ?? Infinity) - (b.size ?? Infinity))
            .map(({ name, size }, i) => [
              i + 1,
              wrap(name),
              size ? formatSize(size, { minimumFractionDigits: 7 }) : '-',
            ]),
        ],
        {
          align: ['l', 'l', 'r'],
        }
      )
  )
  .join('\n\n')}

</td>
<td>

${markdownTable(
  [
    ['#', 'name', 'rss'],
    ...results
      .slice()
      .sort((a, b) => a.max_rss.max_rss - b.max_rss.max_rss)
      .map(({ name, max_rss }, i) => [i + 1, wrap(name), formatSize(max_rss.max_rss, { minimumFractionDigits: 7 })]),
  ],
  {
    align: ['l', 'l', 'r'],
  }
)}

</td>
</tr>
</table>

> - <sup>1</sup>: only includes compiled files (i.e., does not include runtimes or libraries required for execution)

${markdownTable(
  [
    ['name', 'cycles', 'instructions'],
    ...results
      .slice()
      .sort((a, b) => a.cycles - b.cycles)
      .map(({ name, cycles, instructions }) => [name, cycles, instructions]),
  ],
  {
    align: ['l', 'r', 'r'],
  }
)}

Note that cycles are counted with \`perf\` and are only estimates of the actual CPU cycles used, as this can vary.

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
