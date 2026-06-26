# 👤 Fail-Fast — Cẩm nang NGƯỜI DÙNG (template dual-use)

> **Nguyên lý vàng:** *Agent chỉ giỏi bằng context bạn đưa.* Output của bạn ở **P0–P1** quyết định ~80% chất lượng kết quả.
>
> **Template dual-use:** mọi template dưới đây ở dạng **YAML có cấu trúc** → người đọc nhãn tiếng Việt để điền tay; agent `parse` trực tiếp và `merge` vào [`fail-fast-tracker.yaml`](./fail-fast-tracker.yaml).

**Quy ước dùng chung (người & agent):**
- Giữ nguyên **tên field** (khóa tiếng Anh); chỉ thay **giá trị**.
- Giá trị `null` / `[]` / `""` = "chưa có" → đó là việc cần làm.
- Mỗi artifact điền xong → dán vào đúng bet trong `fail-fast-tracker.yaml`.

---

## 🏗️ Việc 0 (1 LẦN cho cả studio) — Chốt stack chuẩn (`studio_stack`)
- **Người + 🤖 Winston:** Winston đề xuất framework/ad-network (có thể `WebSearch` bản mới nhất), **người duyệt & khóa**. Quyết 1 lần → mọi bet tái dùng (vũ khí Base Code). KHÔNG để mỗi bet chọn lại stack.
- **Agent:** đọc `studio_stack`; nếu `decided: false` → nhắc người chốt trước khi build.

```yaml
studio_stack:
  decided: true
  platform_default: "mobile-android"   # mobile-android | mobile-ios | mobile-cross | web | desktop
  framework: "Flutter"                 # vd
  language: "Dart"
  ad_network: "AppLovin MAX"           # vd
```

---

## 🟦 P0 — Việc của bạn (pha NGƯỜI làm chính)

### Việc 1b — Xác định loại app của bet (`platform`)
- **Người:** chọn `target` cho ván này; để `stack_override` rỗng nếu theo studio.
- **Agent:** nếu `stack_override` rỗng → dùng `studio_stack`; có giá trị → dùng override (đọc `rationale`).

```yaml
platform:
  target: "mobile-android"     # loại app đích
  current_form: ""             # dạng hiện tại (vd web-prototype để test nhanh)
  rationale: ""                # vì sao platform này
  stack_override: ""           # rỗng = theo studio_stack
```


### Việc 1 — Tờ ý tưởng thô (`raw_idea`)
- **Người:** điền 4 dòng mô tả.
- **Agent:** đọc `raw_idea` làm định hướng toàn bộ bet; nếu field trống → hỏi người dùng trước khi làm tiếp.

```yaml
raw_idea:
  summary: ""        # 1-2 câu: làm app gì
  audience: ""       # ai dùng (vd: game thủ thích custom màn hình)
  win_reason: ""     # vì sao thắng đối thủ (góc cải tiến cốt lõi)
  iaa_type: ""       # reward | interstitial | native
```

### Việc 2 — Phân tích đối thủ (`competitors`)
- **Người:** tải 3-5 app top, điền bảng. Cột `edge` = điểm mình hơn = mầm của `hook`.
- **Agent:** tổng hợp `edge` các đối thủ → đề xuất `hook` cho bet.

```yaml
competitors:
  - name: ""         # tên app
    store_url: ""    # link store
    main_flow: ""    # flow chính (3-5 bước)
    ad_points: ""    # chèn quảng cáo ở đâu
    edge: ""         # điểm yếu của họ -> mình hơn ở đâu
  # copy thêm 2-4 mục nữa
```

### Việc 3 — Chốt Kill-criteria (`kill_criteria`) — cổng "Fail"
- **Người:** quyết ngưỡng giết **trước khi build**. Số phải cụ thể.
- **Agent:** ở P3, so `metrics` với `kill_criteria` để đề xuất keep/kill (không tự quyết).

```yaml
kill_criteria:
  d1_retention_min: 0.25   # giữ chân ngày 1 tối thiểu
  ecpm_usd_min: 2.5        # eCPM tối thiểu
  crash_free_min: 0.99     # tỉ lệ không crash tối thiểu
  evaluate_after_days: 3   # cửa sổ đo trước khi quyết
```

### Việc 4 — Tạo bet
- **Người + Agent:** gộp 3 artifact trên + định danh → 1 block trong `pipeline`.

```yaml
- id: bet-00X
  title: ""
  phase: P0-hunt
  status: active
  owners: ["analyst:Mary"]
  platform: { target: "", current_form: "", rationale: "", stack_override: "" }
  raw_idea: { summary: "", audience: "", win_reason: "", iaa_type: "" }
  competitors: []
  hook: ""                 # rút ra từ competitors[].edge
  kill_criteria: {}        # rỗng = dùng default_kill_criteria
  spec_input: {}           # điền ở P1
  metrics: { d1_retention: null, ecpm_usd: null, crash_free: null, measured_on: null }
  decision: pending
  artifacts: { tech_spec: null, repo: null, tracking_dashboard: null }
  tasks: []
  notes: ""
```

**✅ Cổng ra P0:** `raw_idea`, `competitors`, `hook`, `kill_criteria` đều đã có giá trị.

---

## 🟩 P1 — Việc của bạn: nuôi spec cho Barry (`*TS`)

### Việc 5 — Mô tả cho Barry
- **Người:** dán `raw_idea` + `competitors` cho Barry khi gọi `*TS`.

### Việc 6 — Trả lời câu hỏi làm rõ (`spec_input`)
- **Người:** điền checklist. Mục `out_of_scope` quan trọng ngang `must_have` — nó chặn agent "vẽ rắn thêm chân".
- **Agent (Barry):** đọc `spec_input` làm xương sống cho tech-spec; thiếu mục nào → hỏi lại đúng mục đó.

```yaml
spec_input:
  must_have: []          # tính năng MVP tối thiểu
  out_of_scope: []       # KHÔNG làm trong ván này (chặn scope creep)
  tech_constraints: []   # stack, nền tảng, SDK ads bắt buộc
  reuse_from_base: []    # module có sẵn trong Base Code dùng lại
  assets_api: []         # asset/API đã có & còn thiếu
```

### Việc 7 — Duyệt tech-spec (**cổng người-quyết #1**)
- **Người:** kiểm 3 thứ trước khi chốt:

```yaml
spec_review:
  tasks_clear: false        # Tasks đủ rõ để làm tuần tự?
  ac_measurable: false      # AC viết Given/When/Then, đo được?
  context_complete: false   # dev mới đọc có vấp chỗ nào không?
  approved: false           # true = chốt
```
- **Output khi `approved: true`:** điền `artifacts.tech_spec` = đường dẫn file spec.

**✅ Cổng ra P1:** `spec_review.approved: true` + `artifacts.tech_spec` có đường dẫn.

---

## 🟨 P2 — Việc của bạn: chốt chất lượng & gắn tiền

### Việc 8 — Duyệt findings adversarial review
- **Agent:** liệt kê findings. **Người:** mỗi finding quyết `fix` / `skip` (kèm lý do).

```yaml
findings_decision:
  - id: ""        # mã finding agent đưa
    action: ""    # fix | skip
    reason: ""    # vì sao (bắt buộc nếu skip)
```

### Việc 9 — Nhúng Ad SDK thật + tracking (việc TAY người)
- **Người:** gắn SDK/key thật. **Agent (Murat):** xác nhận crash-free.

```yaml
ship_checklist:
  ad_sdk_integrated: false   # SDK + ad unit id thật
  tracking_live: false       # đo được D1 / eCPM / crash-free
  crash_free_verified: false # Murat xác nhận đạt ngưỡng
```
**✅ Cổng ra P2:** cả 3 = `true` → đặt bet `status: shipped`.

---

## 🟥 P3 — Việc của bạn: đo & phán quyết (pha NGƯỜI làm chính)

### Việc 10 — Nhập số liệu thật (`metrics`)
- **Người:** sau `evaluate_after_days`, lấy số từ dashboard điền vào.

```yaml
metrics:
  d1_retention: 0.0
  ecpm_usd: 0.0
  crash_free: 0.0
  measured_on: ""      # YYYY-MM-DD
```

### Việc 11 — Quyết định giết/giữ (**cổng người-quyết #2**)
- **Agent (John):** đối chiếu `metrics` vs `kill_criteria`, đề xuất.
- **Người:** quyết cuối + ghi nhật ký.

```yaml
decision: keep         # keep | kill
# rồi thêm 1 dòng vào decision_log:
# - { date: "", bet: "", by: "", action: "", why: "" }
```

- `keep` → đầu tư tiếp (có thể nâng lên Full BMad Method).
- `kill` → `phase: archived` + rút bài học, quay lại P0 bet mới.

---

## 📌 Bảng tổng: việc người → output → lợi ích context

| Việc người | Field output | Vì sao agent cần |
|---|---|---|
| Tờ ý tưởng thô | `raw_idea` | định hướng toàn bộ |
| Phân tích đối thủ | `competitors` | ra `hook` chuẩn |
| Kill-criteria | `kill_criteria` | mới "Fail" được |
| Trả lời Barry | `spec_input` | chặn vẽ rắn thêm chân |
| Duyệt spec | `spec_review` | dev không vấp |
| Nhập số liệu | `metrics` | mới quyết được |

## ⚠️ 3 lỗi context khiến agent làm dở
1. **Bỏ trống `out_of_scope`** → agent over-build.
2. **`kill_criteria` mơ hồ** → không bao giờ giết → kẹt vốn.
3. **`raw_idea.summary` cụt 1 dòng** → agent đoán mò.

---

## 🔗 Liên quan
- Quy trình tổng: [`docs/fail-fast-playbook.md`](./fail-fast-playbook.md)
- Trạng thái pipeline: [`docs/fail-fast-tracker.yaml`](./fail-fast-tracker.yaml)
