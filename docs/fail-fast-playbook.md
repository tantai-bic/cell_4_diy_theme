# 🚀 Fail-Fast Playbook — Studio 6 người (mô hình IAA / Publisher)

> **Khẩu quyết:** *"Không phát minh lại bánh xe."* Tận dụng tối đa thị trường, đóng gói vào bộ khung chuẩn, tung MVP nhanh nhất cho Publisher test — và **dám giết** kẻ thua đúng hạn.

**Phiên bản:** 2026-06-26 · **Nguồn chân lý trạng thái:** [`docs/fail-fast-tracker.yaml`](./fail-fast-tracker.yaml)

---

## 1. Triết lý cốt lõi

| Nguyên tắc | Ý nghĩa |
|---|---|
| **Studio = xưởng tinh nhuệ** | Publisher nắm thị trường + ngân sách UA. Ta thắng bằng **tốc độ, độ mượt, UI chỉn chu**. |
| **IAA là trọng tâm** | Mọi flow thiết kế để hiển thị quảng cáo tối ưu **mà không làm user phật ý**. |
| **Copy & Enhance** | Bóc flow 3-5 app top → làm đẹp/mượt hơn. Không nghiên cứu persona dài dòng. |
| **Lean ≠ bừa** | Cắt giấy tờ, KHÔNG cắt kỷ luật. Mỗi việc có *definition of done*. |
| **Fast *và* Fail** | "Nhanh" vô nghĩa nếu không **đo để giết**. Kill-gate là bắt buộc. |

---

## 2. Toàn cảnh 4 pha

```
[P0] Săn ý tưởng + Kill-gate  →  [P1] Tech-Spec 1 trang
        →  [P2] Quick-Dev (code+test+review)  →  [P3] Ship → Đo → GIỮ/GIẾT
```

- **P1 + P2** = BMAD Quick Flow (có sẵn, agent lo).
- **P0 + P3** = phần "Fail-fast" bạn tự gắn (kill-gate + đo lường ngoài BMAD).

**Ký hiệu:** 👤 = người/PO · 🤖 = agent BMAD

---

## 3. Roster agent

| Agent | Icon | Vai trò trong Fail-fast |
|---|---|---|
| Mary | 📊 | Bóc đối thủ, đề xuất hook, chốt kill-criteria (P0) |
| Barry | 🚀 | Tech-Spec (`*TS`) + Quick-Dev (`*QD`) end-to-end |
| Amelia | 💻 | Dev story chi tiết (khi cần luồng đầy đủ hơn) |
| Sally | 🎨 | Soát luồng IAA không phá UX (P1) |
| Murat | 🧪 | Quality gate: test Ad SDK + crash-free (P2) |
| John | 📋 | Đối chiếu metrics vs kill-criteria, hỗ trợ quyết định (P3) |

---

## 4. Quy trình step-by-step

### 🟦 PHA P0 — Săn ý tưởng & chốt Kill-gate
> Tracker: `phase: P0-hunt`. Cổng ra: có `hook` rõ + `kill_criteria` đã chốt.

| # | Ai | Hành động | Output / Tracker |
|---|----|-----------|------------------|
| 1 | 👤 | Nêu ý tưởng + tải 3-5 app đối thủ | — |
| 2 | 🤖 Mary | Bóc flow đối thủ, chỉ ra 1 "hook" cải tiến | `source` + `hook` |
| 3 | 👤 + 🤖 Mary | **Chốt `kill_criteria`** (D1, eCPM, crash-free, window) | `kill_criteria` |
| 4 | 👤 | Duyệt "đáng cược không?" → tạo bet | Thêm block vào `pipeline`, `status: active` |

### 🟩 PHA P1 — Tech-Spec 1 trang
> Agent: **Barry** `*TS`. Tracker: `phase: P1-spec`. Cổng ra: spec đủ context cho 1 dev mới.

| # | Ai | Hành động | Output / Tracker |
|---|----|-----------|------------------|
| 5 | 👤 | Gọi Barry `*TS`, mô tả cái cần build | — |
| 6 | 🤖 Barry | Hỏi scope/ràng buộc; khảo sát code nếu brownfield | Nắm pattern, file cần sửa |
| 7 | 🤖 Barry | Sinh tech-spec: Tasks `[ ]` + AC (Given/When/Then) | `tech-spec-{slug}.md` |
| 8 | 👤 | Review spec → chốt | `artifacts.tech_spec` = đường dẫn |
| 9 | 🤖 Sally *(nếu có UI)* | Soát luồng IAA không phá UX | Ghi chú vào spec |

### 🟨 PHA P2 — Quick-Dev (build + tự review)
> Agent: **Barry/Amelia** `*QD`, chạy **fresh context**. Tracker: `phase: P2-build`.
> Cổng ra: crash-free đạt ngưỡng + SDK/tracking đã gắn.

| # | Ai | Hành động (6 bước nội tại) | Tracker |
|---|----|-----------|---------|
| 10 | 🤖 Dev | Mode detection → chụp `baseline_commit` | — |
| 11 | 🤖 Dev | Context gathering (file, pattern, deps) | — |
| 12 | 🤖 Dev | Execute: code **+ viết test** theo pattern | tick `tasks[]` |
| 13 | 🤖 Dev | Self-check: đối chiếu Task/Test/AC | — |
| 14 | 🤖 Dev | Adversarial review: dựng diff, tự bắt lỗi | findings |
| 15 | 👤 + 🤖 Dev | Resolve findings: duyệt & sửa | — |
| 16 | 🤖 Murat | **Bắt buộc:** test Ad SDK + crash-free | gate PASS/FAIL |
| 17 | 👤 | Nhúng Ad SDK thật + tracking, build bản ship | `status: shipped` |

### 🟥 PHA P3 — Ship → Đo → Giết/Giữ
> **Ngoài BMAD** — đây là chữ "Fail". Tracker: `phase: P3-measure`.

| # | Ai | Hành động | Tracker |
|---|----|-----------|---------|
| 18 | 👤 | Giao bản MVP cho Publisher test | `status: shipped` |
| 19 | 👤 | Sau `window`: nhập số liệu | `metrics` + `measured_on` |
| 20 | 🤖 Mary/John | Đối chiếu `metrics` vs `kill_criteria` | đề xuất keep/kill |
| 21 | 👤 | **Quyết định cuối** | `decision: keep \| kill`, `status: decided` |
| 22 | 🤖 bất kỳ | Ghi nhật ký | thêm dòng `decision_log` |

- **keep** → đầu tư tiếp (có thể nâng lên Full BMad Method).
- **kill** → `phase: archived`, rút bài học, quay lại P0.

---

## 5. Swimlane (ai sở hữu pha nào)

```
P0-hunt    →  👤 + 🤖 Mary 📊       (ý tưởng + kill_criteria)
P1-spec    →  🤖 Barry 🚀 (+Sally 🎨)  (tech-spec, 👤 duyệt)
P2-build   →  🤖 Dev 💻 (+Murat 🧪)    (code+test+review, 👤 nhúng SDK)
P3-measure →  👤 chủ đạo (+🤖 John 📋)  (đo & quyết định giết/giữ)
```

---

## 6. Ba nguyên tắc bất biến

1. **Mọi bước phản chiếu vào `fail-fast-tracker.yaml`** — không cập nhật = coi như chưa làm.
2. **Người giữ 2 cổng quyết định:** duyệt spec (#8) và quyết định giết/giữ (#21). **Agent không tự giết bet.**
3. **Quality gate của Murat (#16) không được skip** — crash khi gọi ads = Publisher loại ngay.

---

## 7. Nhịp độ mục tiêu

- **3 cặp × 2 người**, mỗi cặp ~1 ván/tuần → **~12 MVP/tháng** đưa Publisher test.
- Chốt convention **một lần** trong `project-context.md` → setup mỗi app tính bằng *giờ*, không phải *tuần*.

---

## 8. Tài liệu liên quan

- **Trạng thái pipeline:** [`docs/fail-fast-tracker.yaml`](./fail-fast-tracker.yaml)
- **Convention code dùng chung:** `project-context.md` *(nên tạo)*
- **BMAD Quick Flow:** agent Barry 🚀 — `*TS` (create-tech-spec) → `*QD` (quick-dev)
