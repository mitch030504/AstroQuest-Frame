// SPDX-FileCopyrightText: Copyright 2026 shadPS4 Emulator Project
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <vector>

#include "core/vr/vr_runtime.h"

namespace Core::Vr {

/// A stereo map has the eyes side by side; otherwise the whole width is one eye.
// ponytail: one eye's fov serves both; the right eye's in/out asymmetry (<1 degree on Frame)
// shifts its map slightly. Mirror the fov for the right eye if a headset is more lopsided.
inline std::vector<u8> BuildFoveationMap(u32 width, u32 height, u32 texel_width,
                                         u32 texel_height, const Fov& fov,
                                         const GazeTarget& gaze, bool stereo = true) {
    if (width == 0 || height == 0 || texel_width == 0 || texel_height == 0) {
        return {};
    }
    const u32 map_width = (width + texel_width - 1) / texel_width;
    const u32 map_height = (height + texel_height - 1) / texel_height;
    std::vector<u8> rates(map_width * map_height, 0);
    if (!gaze.valid || width < 2) {
        return rates;
    }

    constexpr u8 Rate1x1 = 0;
    constexpr u8 Rate2x2 = 5;
    constexpr u8 Rate4x4 = 10;
    constexpr float RadiansToDegrees = 57.2957795131f;
    for (u32 y = 0; y < map_height; ++y) {
        const float v = std::min((y * texel_height + texel_height * 0.5f) / height, 1.0f);
        const float tan_y = (1.0f - v) * fov.tan_top - v * fov.tan_bottom;
        for (u32 x = 0; x < map_width; ++x) {
            const float u = std::min((x * texel_width + texel_width * 0.5f) / width, 1.0f);
            const u32 eye = stereo && u >= 0.5f ? 1 : 0;
            const float local_u = !stereo ? u : eye == 0 ? u * 2.0f : u * 2.0f - 1.0f;
            const float tan_x = -fov.tan_out + local_u * (fov.tan_out + fov.tan_in);
            const float gaze_x = eye == 0 ? gaze.left_x * 2.0f : gaze.right_x * 2.0f - 1.0f;
            const float gaze_tan_x = -fov.tan_out + gaze_x * (fov.tan_out + fov.tan_in);
            const float gaze_tan_y = (1.0f - gaze.y) * fov.tan_top - gaze.y * fov.tan_bottom;
            const float dx = std::atan(tan_x) - std::atan(gaze_tan_x);
            const float dy = std::atan(tan_y) - std::atan(gaze_tan_y);
            const float angle = std::hypot(dx, dy) * RadiansToDegrees;
            rates[y * map_width + x] =
                angle <= 10.0f ? Rate1x1 : angle <= 35.0f ? Rate2x2 : Rate4x4;
        }
    }
    return rates;
}

} // namespace Core::Vr
