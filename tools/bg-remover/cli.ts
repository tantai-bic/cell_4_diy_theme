import os from 'node:os';
import { parseArgs } from 'node:util';
import { DEFAULT_OPTIONS } from './constants';
import { jobsFromFolder, jobsFromManifest } from './inputs';
import { processJob } from './processor';
import { runPool } from './pool';
import type { ImageJob, RemoveBgOptions } from './types';

const HELP = `Tách nền xám (giữ chủ thể viền trắng) → PNG trong suốt.

Usage:
  npm run cut -- --folder <dir>     [--out <dir>] [--tolerance 32] [--feather 1] [--concurrency N]
  npm run cut -- --manifest <json>  [--out <dir>] [--tolerance 32] [--feather 1] [--concurrency N]

Options:
  --folder       Quét mọi ảnh trong folder
  --manifest     Đọc danh sách từ manifest.json ([{file,id,...}])
  --out          Thư mục xuất (mặc định: output)
  --tolerance    Ngưỡng khớp màu nền 0-441 (mặc định ${DEFAULT_OPTIONS.tolerance}); cao = xoá mạnh
  --feather      Bán kính làm mềm mép, px (mặc định ${DEFAULT_OPTIONS.feather}; 0 = mép cứng)
  --concurrency  Số ảnh xử lý song song (mặc định = số CPU - 1)

Examples:
  npm run cut -- --folder assets/sticker --out output/sticker
  npm run cut -- --manifest assets/sticker/manifest.json --out output/sticker`;

async function main() {
  const { values } = parseArgs({
    options: {
      folder: { type: 'string' },
      manifest: { type: 'string' },
      out: { type: 'string', default: 'output' },
      tolerance: { type: 'string' },
      feather: { type: 'string' },
      concurrency: { type: 'string' },
      help: { type: 'boolean', short: 'h' },
    },
  });

  if (values.help || (!values.folder && !values.manifest)) {
    console.log(HELP);
    process.exit(values.help ? 0 : 1);
  }

  const opts: RemoveBgOptions = {
    ...DEFAULT_OPTIONS,
    tolerance: values.tolerance ? Number(values.tolerance) : DEFAULT_OPTIONS.tolerance,
    feather: values.feather ? Number(values.feather) : DEFAULT_OPTIONS.feather,
  };
  const outDir = values.out as string;
  const concurrency = values.concurrency
    ? Number(values.concurrency)
    : Math.max(1, os.cpus().length - 1);

  const jobs: ImageJob[] = values.manifest
    ? await jobsFromManifest(values.manifest, outDir)
    : await jobsFromFolder(values.folder as string, outDir);

  if (!jobs.length) {
    console.error('Không tìm thấy ảnh đầu vào.');
    process.exit(1);
  }

  console.log(
    `▶ ${jobs.length} ảnh · concurrency=${concurrency} · tolerance=${opts.tolerance} · feather=${opts.feather}`,
  );

  let done = 0;
  let failed = 0;
  const results = await runPool(jobs, concurrency, async (job) => {
    const r = await processJob(job, opts);
    done++;
    if (r.ok) {
      const pct = ((r.removedPixels! / r.totalPixels!) * 100).toFixed(1);
      console.log(`✓ [${done}/${jobs.length}] ${job.output}  (nền ${pct}%, ${r.ms}ms)`);
    } else {
      failed++;
      console.error(`✗ [${done}/${jobs.length}] ${job.input} — ${r.error}`);
    }
    return r;
  });

  const ok = results.filter((r) => r.ok).length;
  console.log(`\nXong: ${ok} ok, ${failed} lỗi → ${outDir}`);
  if (failed) process.exit(1);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
