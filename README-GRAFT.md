# ovaltine24 — wly 骨架 + 10T 定制

> 生成：2026-11-06 ｜ 汐
> 骨架来源：`pjgowtham/android_device_oneplus_wly@lineage-24.0`（该分支 2026-11-04 已出 1.8 GB 完整包）
> 机型数据来源：`MagicNeko-ROM/android_device_oneplus_ovaltine@lineage-23.2`（自维护，CPH2415 基线）

---

## 为什么要这么做

`wly@lineage-24.0` 是当前唯一「24.0 + 6.6 + 完整出包」的一加设备树，骨架是活的。
10T(ovaltine) 与 wly(10 Pro) 共用 `device/oneplus/sm8450-common`，平台层接得上。
所以拿它当骨架、把 10T 的机型数据填进去，比从 23.2 硬迁 24.0 省事。

**注意**：wly 是 waipio（SM8450），ovaltine 是 cape（SM8475），机型层不能照抄。

---

## 做了什么

| # | 改动 | 原因 |
|---|---|---|
| 1 | 全树 `wly` → `ovaltine`（5 个文件、1 个文件名） | 设备名 |
| 2 | `BoardConfig.mk`：`TARGET_RECOVERY_UI_MARGIN_HEIGHT` 126 → **103** | 10T 挖孔/状态栏高度与 10 Pro 不同 |
| 3 | `BoardConfig.mk`：加 `BOARD_PRODUCTIMAGE_PARTITION_RESERVED_SIZE := 900000000` | 10T 的 product 分区预留 |
| 4 | `BoardConfig.mk`：删 VINTF 段与 `vintf/` 目录 | 那个 compatibility_matrix 只声明人脸 HAL，10T 没有 |
| 5 | `BoardConfig.mk`：加 `-include vendor/extra/BoardConfigExtra.mk` | 10T 用 vendor/extra |
| 6 | `device.mk`：`PRODUCT_AAPT_PREF_CONFIG` xxxhdpi → **xxhdpi** | 10T 是 1080p，wly 是 1440p |
| 7 | `device.mk`：`TARGET_SCREEN_HEIGHT/WIDTH` 3216×1440 → **2412×1080** | 开机动画分辨率 |
| 8 | `device.mk`：删 Alert slider（`KeyHandler` + `tri-state-key-calibrate`） | **10T 没有三段式静音键**（XDA/The Verge/IT之家/网易四方确认） |
| 9 | `device.mk`：删 `overlay/KeyHandlerResTarget` 包 | 同上 |
| 10 | `device.mk`：删 `soong_config_set(qtidisplay,pxlw_vendor_namespace,...)` | **10T 无 Pixelworks iris**，设了会要求 libpwirisfeature |
| 11 | `device.mk`：`soong_config_set` → `soong_config_set_bool`（oplus_udfps） | qtidisplay 里声明的是 bool_variables |
| 12 | `device.mk`：音频段换成 10T 的（`mixer_paths.xml` / `resourcemanager.xml`，删 `sound_trigger_*`） | 文件名与 wly 不同，10T 树没有 sound_trigger |
| 13 | `device.mk`：指纹 `@2.3-service.oplus` 注释掉 | 10T 用 stock HAL（odm 注册 IFingerprint/default） |
| 14 | `device.mk`：NFC 补 `libnfc-nxp.conf` / `libnfc-nci.conf` / `sn100u.bin` | 10T 的 NFC 是 SN110T，需要这些配置 |
| 15 | `device.mk`：加 Power 段 `soong_config_set(qtipower,mode_ext_lib,power-ext-oplus)` | 10T 的 power HAL |
| 16 | `device.mk`：加 `vendor/extra` inherit + `persist.sys.root_access=3` | 10T 原有配置 |
| 17 | `lineage_ovaltine.mk`：`PRODUCT_MODEL` NE2213 → **CPH2415**，fingerprint 换 10T 的 | 机型标识 |
| 18 | `board-info.txt`：`OP516FL1` → **`OP5551L1|OP5552L1`** | 板名 |
| 19 | `vendor.prop`：`OnePlus 10 Pro 5G` → **`OnePlus 10T 5G`** | 设备名 |
| 20 | `overlay/`：整目录换 10T 版本 | 挖孔位置、圆角、dimens 都是机型专属 |
| 21 | `overlay-lineage/`：Aperture 用 10T 的，保留 wly 的 lineage-sdk / Settings | 24.0 新增项保留 |
| 22 | `audio/`：整目录换 10T 版本 | 同上 |
| 23 | `proprietary-files.txt` / `proprietary-firmware.txt`：用 10T 的（1601 / 43 行） | CPH2415 基线 |

---

## 没做的事（故意的）

- **没带 GPU_DRIVER_Q3 / Vulkan switcher**：依赖 `vendor/oneplus/sm8450-common/gpu-q3/gpu-q3.mk`，先跑通再加
- **没带 fingerprint proxy HAL**：23.2 那边已停用（AIDL V4/V5 不匹配，会 boot-loop）
- **没带 qprobe/、docs/**：自研工具，不影响构建
- **没改 overlay 里的 24.0 新增项**：wly 有而 10T 没有的，暂时用默认值

---

## 下一步

1. 放进源码树：`device/oneplus/ovaltine/`，vendor 用 `proprietary_vendor_oneplus_ovaltine`（CPH2415 基线）
2. 内核用 PJG `lineage-24.0`（6.6.144）+ devicetrees（含 `ovaltine-21841/21845-cape-overlay`）
3. `lunch lineage_ovaltine-*` 编译，看能不能过 soong/kati
4. 过了再谈刷机

---

## 已知风险

- **super 分区**：24.0 的 super 有 14 个分区（多 `system_dlkm_a/b`），你设备的 metadata 只有 12 个，fstab 里的 `system_dlkm` 挂载行会对不上
- **libtinyxml2**：你的 vendor 只有 `libtinyxml2_1.so`，缺 `libtinyxml2.so` / `-v34` / `-v36`
- **这套树不保证能开机**：卡 logo 的根因还没定，但换这套能排除「设备树有问题」这个变量
