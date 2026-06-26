import type { RemoveBgOptions } from './types';

export const DEFAULT_OPTIONS: RemoveBgOptions = {
  tolerance: 32,
  samplePadding: 4,
  feather: 1,
  // Nới rộng để nhận cả nền xám sáng (~220); viền trắng (~255) vẫn được chặn
  // bằng khoảng cách màu so với nền lấy mẫu (auto-adapt theo từng ảnh).
  maxBackgroundLuma: 245,
};

/** Phần mở rộng ảnh được nhận khi quét folder. */
export const IMAGE_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.webp'] as const;
