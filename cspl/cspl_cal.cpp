/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * Load the factory speaker calibration into the CS35L41 CSPL firmware,
 * like the stock audio HAL does in audio_extn_cspl_sp_init().
 */

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/parseint.h>
#include <android-base/strings.h>
#include <endian.h>
#include <tinyalsa/asoundlib.h>

#include <chrono>
#include <cstdint>
#include <string>
#include <thread>

using namespace std::chrono_literals;

namespace {

constexpr unsigned int kCard = 0;
constexpr int kRetries = 100;
constexpr auto kRetryDelay = 100ms;

constexpr char kCalRPath[] = "/mnt/vendor/persist/factory/audio/spk_cal_r";
constexpr char kCalAmbientPath[] = "/mnt/vendor/persist/factory/audio/spk_ambient";

constexpr char kCtlPrefix[] = "SPK DSP1X protection cd ";
constexpr char kDspBootedCtl[] = "SPK DSP Booted";
constexpr char kDspPreloadCtl[] = "SPK DSP1 Preload Switch";

constexpr uint32_t kCalStatusCalibrated = 1;

bool ReadCalValue(const char* path, uint32_t* value) {
    std::string buf;
    if (!android::base::ReadFileToString(path, &buf)) {
        PLOG(ERROR) << "Failed to read " << path;
        return false;
    }
    if (!android::base::ParseUint(android::base::Trim(buf), value)) {
        LOG(ERROR) << "Failed to parse " << path << ": " << buf;
        return false;
    }
    return true;
}

struct mixer_ctl* GetCsplCtl(struct mixer* mixer, const std::string& name) {
    return mixer_get_ctl_by_name(mixer, (std::string(kCtlPrefix) + name).c_str());
}

// CSPL controls are 4 byte big endian words
bool SetCsplCtl(struct mixer* mixer, const std::string& name, uint32_t value) {
    struct mixer_ctl* ctl = GetCsplCtl(mixer, name);
    uint32_t data = htobe32(value);
    if (!ctl || mixer_ctl_set_array(ctl, &data, sizeof(data))) {
        LOG(ERROR) << "Failed to set " << name;
        return false;
    }
    return true;
}

bool GetCsplCtl(struct mixer* mixer, const std::string& name, uint32_t* value) {
    struct mixer_ctl* ctl = GetCsplCtl(mixer, name);
    uint32_t data;
    if (!ctl || mixer_ctl_get_array(ctl, &data, sizeof(data))) {
        LOG(ERROR) << "Failed to get " << name;
        return false;
    }
    *value = be32toh(data);
    return true;
}

bool SetCtl(struct mixer* mixer, const char* name, int value) {
    struct mixer_ctl* ctl = mixer_get_ctl_by_name(mixer, name);
    if (!ctl || mixer_ctl_set_value(ctl, 0, value)) {
        LOG(ERROR) << "Failed to set " << name;
        return false;
    }
    return true;
}

bool CalApplied(struct mixer* mixer, uint32_t cal_r) {
    uint32_t selected;
    return GetCsplCtl(mixer, "CAL_R_SELECTED", &selected) && selected == cal_r;
}

// The CSPL controls show up once the amp firmware has been loaded
struct mixer* WaitForCsplMixer() {
    for (int i = 0; i < kRetries; i++) {
        struct mixer* mixer = mixer_open(kCard);
        if (mixer) {
            if (GetCsplCtl(mixer, "CAL_R")) return mixer;
            mixer_close(mixer);
        }
        std::this_thread::sleep_for(kRetryDelay);
    }
    return nullptr;
}

}  // anonymous namespace

int main(int /* argc */, char** argv) {
    android::base::InitLogging(argv, android::base::LogdLogger(android::base::MAIN));

    uint32_t cal_r, ambient;
    if (!ReadCalValue(kCalRPath, &cal_r) || !ReadCalValue(kCalAmbientPath, &ambient)) {
        LOG(INFO) << "Speaker not calibrated, keeping firmware defaults";
        return 0;
    }

    struct mixer* mixer = WaitForCsplMixer();
    if (!mixer) {
        LOG(ERROR) << "CSPL controls not found";
        return 1;
    }

    if (CalApplied(mixer, cal_r)) {
        LOG(INFO) << "Calibration already applied (ReDC " << cal_r << ")";
        mixer_close(mixer);
        return 0;
    }

    if (!SetCsplCtl(mixer, "CAL_R", cal_r) || !SetCsplCtl(mixer, "CAL_AMBIENT", ambient) ||
        !SetCsplCtl(mixer, "CAL_STATUS", kCalStatusCalibrated) ||
        !SetCsplCtl(mixer, "CAL_CHECKSUM", cal_r + kCalStatusCalibrated)) {
        mixer_close(mixer);
        return 1;
    }

    // CSPL only reads the calibration on DSP boot, wm_adsp restores the values set above
    bool rebooted = SetCtl(mixer, kDspBootedCtl, 0) && SetCtl(mixer, kDspPreloadCtl, 0) &&
                    SetCtl(mixer, kDspPreloadCtl, 1);
    mixer_close(mixer);
    if (!rebooted) return 1;

    // The controls get re-registered on DSP boot, so reopen the mixer on every check
    bool applied = false;
    bool booted = true;
    for (int i = 0; i < kRetries && !applied; i++) {
        std::this_thread::sleep_for(kRetryDelay);
        mixer = mixer_open(kCard);
        if (!mixer) continue;
        struct mixer_ctl* booted_ctl = mixer_get_ctl_by_name(mixer, kDspBootedCtl);
        booted = booted_ctl && mixer_ctl_get_value(booted_ctl, 0) > 0;
        applied = booted && GetCsplCtl(mixer, "CAL_R_SELECTED") && CalApplied(mixer, cal_r);
        mixer_close(mixer);
    }

    // The DSP may only start running with the next playback, wm_adsp applies the values then
    if (!applied && !booted) {
        LOG(INFO) << "Calibration queued for next DSP boot (ReDC " << cal_r << ")";
        return 0;
    }

    if (!applied) {
        LOG(ERROR) << "CSPL did not accept calibration (ReDC " << cal_r << ")";
        return 1;
    }

    LOG(INFO) << "Applied speaker calibration: ReDC " << cal_r << ", ambient " << ambient;
    return 0;
}
