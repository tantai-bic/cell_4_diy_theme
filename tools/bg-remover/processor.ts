import { promises as fs } from 'node:fs';
import path from 'node:path';
import sharp from 'sharp';
import type { ImageJob, JobResult, RemoveBgOptions } from './types';
import { featherAlpha, floodRemoveBackground, sampleBackground } from './flood-fill';

/** Load → tách nền → ghi PNG trong suốt cho 1 job. Không ném lỗi: gói vào JobResult. */
export async function processJob(job: ImageJob, opts: RemoveBgOptions): Promise<JobResult> {
  const start = Date.now();
  try {
    const { data, info } = await sharp(job.input)
      .ensureAlpha()
      .raw()
      .toBuffer({ resolveWithObject: true });

    const { width, height } = info;
    const buf = Buffer.from(data); // bản sao mutable

    const bg = sampleBackground(buf, width, height, opts.samplePadding);
    const removed = floodRemoveBackground(buf, width, height, bg, opts);
    featherAlpha(buf, width, height, opts.feather);

    await fs.mkdir(path.dirname(job.output), { recursive: true });
    await sharp(buf, { raw: { width, height, channels: 4 } }).png().toFile(job.output);

    return { job, ok: true, removedPixels: removed, totalPixels: width * height, ms: Date.now() - start };
  } catch (e) {
    return { job, ok: false, error: (e as Error).message, ms: Date.now() - start };
  }
}
