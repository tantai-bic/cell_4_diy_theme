import { promises as fs } from 'node:fs';
import path from 'node:path';
import { IMAGE_EXTENSIONS } from './constants';
import type { ImageJob, ManifestEntry } from './types';

const toPng = (file: string) => path.basename(file, path.extname(file)) + '.png';
const stripBom = (s: string) => s.replace(/^﻿/, '');
const isImage = (name: string) =>
  (IMAGE_EXTENSIONS as readonly string[]).includes(path.extname(name).toLowerCase());

/** Tạo jobs từ mọi ảnh nằm trực tiếp trong 1 folder. */
export async function jobsFromFolder(folder: string, outDir: string): Promise<ImageJob[]> {
  const entries = await fs.readdir(folder, { withFileTypes: true });
  return entries
    .filter((e) => e.isFile() && isImage(e.name))
    .map((e) => ({
      input: path.join(folder, e.name),
      output: path.join(outDir, toPng(e.name)),
    }));
}

/** Tạo jobs từ manifest.json ([{file,id,...}]); đường dẫn resolve theo thư mục chứa manifest. */
export async function jobsFromManifest(manifestPath: string, outDir: string): Promise<ImageJob[]> {
  const raw = stripBom(await fs.readFile(manifestPath, 'utf8'));
  const entries = JSON.parse(raw) as ManifestEntry[];
  const baseDir = path.dirname(manifestPath);
  return entries
    .filter((e) => e?.file)
    .map((e) => ({
      input: path.join(baseDir, e.file),
      output: path.join(outDir, toPng(e.file)),
      id: e.id,
    }));
}
