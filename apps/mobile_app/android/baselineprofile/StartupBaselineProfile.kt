package com.example.anit_scan_2.baselineprofile

import androidx.benchmark.macro.junit4.BaselineProfileRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.filters.LargeTest
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Same instrumentation test a native Android app uses to record a baseline
 * profile. This file is not on the Gradle classpath. The release build uses
 * the checked-in rules in app/src/main/baselineProfiles.
 *
 * When the first screen exists, add an android/baselineprofile module with
 * the androidx.baselineprofile plugin, point it at :app, run this test on a
 * device, and replace those text files with the generated output.
 */
@RunWith(AndroidJUnit4::class)
@LargeTest
class StartupBaselineProfile {
    @get:Rule
    val rule = BaselineProfileRule()

    @Test
    fun startup() {
        rule.collect(
            packageName = "com.example.anit_scan_2",
            includeInStartupProfile = true,
        ) {
            pressHome()
            startActivityAndWait()
        }
    }
}
