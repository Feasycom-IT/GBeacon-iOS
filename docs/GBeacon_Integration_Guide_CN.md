# GBeacon iOS 工程接入说明

## 文件与架构

- [SDK/](../GBeacon/SDK)：`libGBeacon.a`、公开头文件及中英文接口 PDF。
- [CallbackSDK/](../GBeacon/CallbackSDK)：`libFeasyCallbackSDK.a` 与头文件。
- [LibSensor/](../GBeacon/Modules/Beacon/LibSensor)：`libsensor.a` 与 `sensor.h`，用于传感器数据解析。
- 以上静态库均只包含真机 arm64，未包含模拟器切片。

## 打开示例工程

打开根目录 `GBeacon.xcworkspace`，选择 `GBeacon` scheme 和 iPhone 真机。仓库包含 Pods、Podfile 和锁文件，重装依赖时在根目录执行 `pod install`。

主 App target 为 iOS 10，版本 1.0.3，构建号 20260818；Podfile 的历史平台声明不代表主 App 的最低系统要求。真机部署前应改用自己的签名团队和可用 Bundle ID。

## 在自己的项目中接入

将实际功能所需的 SDK 静态库、公开头文件及资源添加到工程，设置 Library Search Paths 和 Header Search Paths。示例工程的 Build Settings 已记录配套库路径，可作为接入参考。

导入 `FBSDKPublicHeader.h`。`FBBluetoothBrowser` 提供扫描能力：

- `FBBluetoothBrowserTypeBeacon`：标准 Beacon 广播（iBeacon、UID、URL、TLM、AltBeacon）。
- `FBBluetoothBrowserTypeSensor`：传感器类自定义广播。
- `FBBluetoothBrowserTypeSetting`：Beacon 设备配置。

按 `FBBluetoothBrowserDelegate` 注册回调，并在蓝牙可用及相应权限就绪后调用 `startScanning`；结束时调用 `stopScanning`。iBeacon 扫描涉及定位能力，应根据应用用途配置和申请权限。

设备参数配置、会话和升级接口分别参考当前 `FBPeripheralManager.h`、`FBSession.h`、`FBUpgradeManager.h` 及对应 App 调用代码。升级文件必须与设备型号及固件要求匹配。

## 接口参考

- [中文接口 PDF](../GBeacon/SDK/FBeacon_iOS_SDK接口文档.pdf)
- [English interface PDF](<../GBeacon/SDK/FBeacon_iOS-SDK Interface Document.pdf>)
- [当前 SDK 公开头文件](../GBeacon/SDK)

本文依据已提供的工程与头文件整理；完整编译和硬件功能测试未在此次仓库整理中执行。
