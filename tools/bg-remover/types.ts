export interface RGB {
  r: number;
  g: number;
  b: number;
}

export interface RemoveBgOptions {
  /** Max khoảng cách màu (0-441) so với nền đã lấy mẫu để coi 1 pixel là nền. */
  tolerance: number;
  /** Số pixel viền mỗi cạnh dùng để ước lượng màu nền. */
  samplePadding: number;
  /** Bán kính feather (px) để làm mềm mép cắt (0 = mép cứng). */
  feather: number;
  /** Luminance tối đa (0-255) 1 pixel được phép có để đủ điều kiện là nền — bảo vệ viền trắng. */
  maxBackgroundLuma: number;
}

export interface ImageJob {
  /** Đường dẫn ảnh nguồn. */
  input: string;
  /** Đường dẫn đích (.png). */
  output: string;
  /** id tuỳ chọn từ manifest, dùng cho log. */
  id?: string;
}

export interface JobResult {
  job: ImageJob;
  ok: boolean;
  removedPixels?: number;
  totalPixels?: number;
  error?: string;
  ms: number;
}

/** 1 entry trong manifest.json. */
export interface ManifestEntry {
  file: string;
  id?: string;
  size?: string;
  title?: string;
}
