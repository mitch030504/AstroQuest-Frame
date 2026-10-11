// SPDX-FileCopyrightText: Copyright 2026 shadPS4 Emulator Project
// SPDX-License-Identifier: GPL-2.0-or-later

#include <cassert>

#include "core/vr/foveation_map.h"

int main() {
    using namespace Core::Vr;
    const Fov fov{1.0f, 1.0f, 1.0f, 1.0f};
    GazeTarget gaze{0.25f, 0.75f, 0.5f, true};
    const auto map = BuildFoveationMap(2048, 1024, 8, 8, fov, gaze);
    assert(map.size() == 256 * 128);
    assert(map[63 * 256 + 63] == 0);
    assert(map[63 * 256 + 191] == 0);
    assert(map[63 * 256 + 85] == 5);
    assert(map[63 * 256] == 10);
    const auto eye = BuildFoveationMap(1024, 1024, 8, 8, fov, gaze, false);
    assert(eye.size() == 128 * 128);
    assert(eye[63 * 128 + 63] == 0);
    assert(eye[63 * 128 + 85] == 5);
    assert(eye[63 * 128] == 10 && eye[63 * 128 + 127] == 10);
    gaze.valid = false;
    const auto fallback = BuildFoveationMap(2048, 1024, 8, 8, fov, gaze);
    assert(fallback.front() == 0 && fallback.back() == 0);
    assert(BuildFoveationMap(0, 1024, 8, 8, fov, gaze).empty());
}
