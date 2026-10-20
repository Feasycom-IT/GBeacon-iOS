# GBeacon iOS Integration Guide

## Package

- [`GBeacon/SDK/`](../GBeacon/SDK) contains `libGBeacon.a`, public headers and Chinese/English interface PDFs.
- [`GBeacon/CallbackSDK/`](../GBeacon/CallbackSDK) contains the companion `libFeasyCallbackSDK.a` and its header.
- [`GBeacon/Modules/Beacon/LibSensor/`](../GBeacon/Modules/Beacon/LibSensor) contains `libsensor.a` and `sensor.h` for sensor data parsing.
- All static libraries contain an arm64 iPhone device slice. Simulator slices and library implementation source are not included.

## Build the demo

Open `GBeacon.xcworkspace`, select scheme `GBeacon` and use a physical iPhone. Pods and the lockfile are included; run `pod install` from the repository root if reinstalling dependencies.

The app target requires iOS 10, version 1.0.3, build 20260818. Its Bundle ID is `com.yanniao.GBeacon`. Use your own signing team and an available Bundle ID for device deployment. The app target requirement differs from the historical platform declared in the Podfile.

Bugly crash reporting is disabled by default. To enable it, replace `YOUR_BUGLY_APP_ID` in `GBeacon/AppDelegate/FWAppDelegate.m` with your own App ID.

## Integrate the SDK

Add the required libraries, headers and resources to your application. Configure library/header search paths using the demo Build Settings as a reference. Import `FBSDKPublicHeader.h`.

`FBBluetoothBrowser` separates Beacon, Sensor and Setting scans through `FBBluetoothBrowserType`. Register `FBBluetoothBrowserDelegate` callbacks, wait for Bluetooth and permissions to become available, then call `startScanning`. Stop scanning with `stopScanning` when finished. Configure and request location permissions when required for iBeacon scanning.

Device configuration, sessions and upgrades are declared in `FBPeripheralManager.h`, `FBSession.h` and `FBUpgradeManager.h`. Follow the corresponding app code and use firmware matching the device model and upgrade requirements.

## Reference

- [English SDK interface PDF](<../GBeacon/SDK/FBeacon_iOS-SDK Interface Document.pdf>)
- [Chinese SDK interface PDF](../GBeacon/SDK/FBeacon_iOS_SDK接口文档.pdf)
- [Current public headers](../GBeacon/SDK)
- [SDK revision notes](../GBeacon/SDK/FBReadMe.md)

PDF documentation may describe an earlier SDK revision; check current public headers for exact method signatures. Repository packaging did not include a full app build or hardware functional tests.
