import type { RemoveBgOptions, RGB } from './types';

const luma = (r: number, g: number, b: number) => 0.299 * r + 0.587 * g + 0.114 * b;

/** Ước lượng màu nền từ vành biên ảnh (median từng kênh — bền với nhiễu). */
export function sampleBackground(
  data: Buffer,
  width: number,
  height: number,
  padding: number,
): RGB {
  const rs: number[] = [];
  const gs: number[] = [];
  const bs: number[] = [];
  const push = (x: number, y: number) => {
    const i = (y * width + x) * 4;
    rs.push(data[i]);
    gs.push(data[i + 1]);
    bs.push(data[i + 2]);
  };
  const pad = Math.min(padding, (Math.min(width, height) / 2) | 0 || 1);
  for (let y = 0; y < height; y++) {
    for (let p = 0; p < pad; p++) {
      push(p, y);
      push(width - 1 - p, y);
    }
  }
  for (let x = 0; x < width; x++) {
    for (let p = 0; p < pad; p++) {
      push(x, p);
      push(x, height - 1 - p);
    }
  }
  const median = (a: number[]) => {
    a.sort((m, n) => m - n);
    return a[a.length >> 1];
  };
  return { r: median(rs), g: median(gs), b: median(bs) };
}

/**
 * Flood-fill từ các cạnh ảnh, xoá (alpha=0) vùng nền liên thông với biên.
 * Viền trắng die-cut chặn fill lại, nên chi tiết bên trong (kể cả màu xám) được giữ.
 * Trả về số pixel đã xoá. Ghi đè `data` tại chỗ.
 */
export function floodRemoveBackground(
  data: Buffer,
  width: number,
  height: number,
  bg: RGB,
  opts: RemoveBgOptions,
): number {
  const n = width * height;
  const visited = new Uint8Array(n);
  const stack = new Int32Array(n);
  let sp = 0;
  // ngân sách khoảng cách bình phương trên 3 kênh
  const tol2 = opts.tolerance * opts.tolerance * 3;

  const isBg = (idx: number): boolean => {
    const i = idx * 4;
    const r = data[i];
    const g = data[i + 1];
    const b = data[i + 2];
    if (luma(r, g, b) > opts.maxBackgroundLuma) return false; // bảo vệ viền trắng
    const dr = r - bg.r;
    const dg = g - bg.g;
    const db = b - bg.b;
    return dr * dr + dg * dg + db * db <= tol2;
  };

  const seed = (idx: number) => {
    if (!visited[idx] && isBg(idx)) {
      visited[idx] = 1;
      stack[sp++] = idx;
    }
  };

  // gieo mầm từ toàn bộ pixel biên
  for (let x = 0; x < width; x++) {
    seed(x);
    seed((height - 1) * width + x);
  }
  for (let y = 0; y < height; y++) {
    seed(y * width);
    seed(y * width + width - 1);
  }

  let removed = 0;
  while (sp > 0) {
    const idx = stack[--sp];
    data[idx * 4 + 3] = 0; // trong suốt
    removed++;
    const x = idx % width;
    const y = (idx / width) | 0;
    if (x > 0) seed(idx - 1);
    if (x < width - 1) seed(idx + 1);
    if (y > 0) seed(idx - width);
    if (y < height - 1) seed(idx + width);
  }
  return removed;
}

/**
 * Làm mềm mép alpha: với mỗi pixel được giữ, alpha = 255 * tỉ lệ neighbor cũng được giữ
 * trong box (2r+1). Pixel nội vùng (mọi neighbor được giữ) → 255 không đổi; chỉ mép rìa bị giảm.
 */
export function featherAlpha(data: Buffer, width: number, height: number, radius: number): void {
  if (radius <= 0) return;
  const n = width * height;
  const kept = new Uint8Array(n);
  for (let i = 0; i < n; i++) kept[i] = data[i * 4 + 3] > 0 ? 1 : 0;

  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const idx = y * width + x;
      if (!kept[idx]) continue;
      let sum = 0;
      let cnt = 0;
      for (let dy = -radius; dy <= radius; dy++) {
        const ny = y + dy;
        if (ny < 0 || ny >= height) continue;
        for (let dx = -radius; dx <= radius; dx++) {
          const nx = x + dx;
          if (nx < 0 || nx >= width) continue;
          sum += kept[ny * width + nx];
          cnt++;
        }
      }
      data[idx * 4 + 3] = Math.round((255 * sum) / cnt);
    }
  }
}
