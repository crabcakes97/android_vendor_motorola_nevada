# Vendor blobs — Motorola Nevada (moto g play 2026, XT2615-1)

Proprietary files for the Nevada Lineage 23 bringup. Syncs to
`vendor/motorola/nevada/` in the build tree (companion of the
`android_device_motorola_nevada` device repo).

## Layout

```text
Android.bp  Android.mk  BoardConfigVendor.mk  nevada-vendor.mk  # generated
proprietary/   # ~2,800 extracted stock files (vendor/, product/,
               #   system/, system_ext/ trees)
radio/         # stock radio/firmware images
```

## Source

Everything extracted from stock RETUS `W1WNS36.18-114-1` firmware; see the
device repo's `proprietary-files.txt` (documents every deviation) and
`extract-files.py` (blob fixups) for exactly how each file was produced.

Four files over GitHub's 100 MB limit (`MotCamera5.apk`, `SettingsMoto.apk`,
`libsdk_sr.so`, `libsdk_sr_2.so`) are stored with Git LFS — install it
(`git lfs install`) before cloning, or re-run `extract-files.py` against a
firmware dump to regenerate `proprietary/` + `radio/` locally instead.
