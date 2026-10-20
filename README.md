# GBeacon iOS App（SDK + Demo）

GBeacon 是 Beacon 设备的扫描、广播展示、参数配置、传感器数据解析和升级 App。本仓库提供 **应用层源码、预编译 SDK、Xcode 工程及中英文接口文档**。

SDK 以静态库和公开头文件交付，不包含静态库的实现源码。

> GBeacon iOS application source with prebuilt SDK libraries, an Xcode workspace and Chinese/English SDK interface documents.

## 1. 下载 / Download

- [浏览应用源码](GBeacon)
- [浏览 Beacon SDK](GBeacon/SDK)

```bash
git clone https://github.com/Feasycom-IT/GBeacon-iOS.git
```

本仓库为私有仓库，克隆前需要有仓库访问权限。

## 2. 引入 SDK / Add the SDK

```text
GBeacon/
├── SDK/
│   ├── libGBeacon.a
│   ├── FBSDKPublicHeader.h
│   ├── FBBluetoothBrowser.h
│   └── ...
├── CallbackSDK/
│   ├── libFeasyCallbackSDK.a
│   └── FeasyCallbackSDK.h
└── Modules/Beacon/LibSensor/
    ├── libsensor.a
    └── sensor.h
```

`libGBeacon.a`、`libFeasyCallbackSDK.a` 和 `libsensor.a` 当前均为 **iPhone 真机 arm64**。SDK 文件、资源和链接配置请按实际使用功能参照示例工程，不支持直接使用这些库构建模拟器目标。

Beacon SDK 的公开入口：

```objc
#import "FBSDKPublicHeader.h"
```

具体 API 以公开头文件及下方接口文档为准。

## 3. 打开与编译 / Build

使用 macOS 和 Xcode，打开 workspace：

```bash
open GBeacon.xcworkspace
```

- Scheme：`GBeacon`。
- 主 App target 最低系统：iOS 10。
- 应用版本：`1.0.3`；构建号：`20260818`。
- Bundle ID：`com.yanniao.GBeacon`。
- 语言：Objective-C / UIKit。
- 仓库包含 Pods 与 `Podfile.lock`；需要重装时在根目录运行 `pod install`。
- 真机运行前选择自己的开发团队和可用的 Bundle ID，并按业务确认蓝牙、定位、相机、相册等权限。
- Bugly 崩溃统计默认关闭；如需启用，把 `GBeacon/AppDelegate/FWAppDelegate.m` 中的 `YOUR_BUGLY_APP_ID` 替换为自己的 App ID。

不签名的真机目标构建命令：

```bash
xcodebuild -workspace GBeacon.xcworkspace -scheme GBeacon \
  -configuration Debug -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO build
```

本次仓库整理验证了文件结构、SDK 架构和工程识别；未完成 App 编译或真机功能验收。

## 4. SDK 文档 / Documents

- [中文 SDK 接口文档（PDF）](GBeacon/SDK/FBeacon_iOS_SDK接口文档.pdf)
- [English SDK interface document（PDF）](<GBeacon/SDK/FBeacon_iOS-SDK Interface Document.pdf>)
- [中文工程接入说明](docs/GBeacon_Integration_Guide_CN.md)
- [English integration guide](docs/GBeacon_Integration_Guide_EN.md)
- [SDK 修订记录](GBeacon/SDK/FBReadMe.md)
- [应用版本记录](CHANGELOG.md)

## 5. 目录结构 / Layout

```text
.
├── GBeacon/                    # App 源码、资源、SDK 与第三方库
│   ├── SDK/                    # Beacon SDK 静态库、头文件和接口 PDF
│   ├── CallbackSDK/            # 配套 Callback SDK
│   └── Modules/                # 各功能模块（含 LibSensor 传感器解析库）
├── GBeacon.xcodeproj/
├── GBeacon.xcworkspace/
├── GBeaconTests/
├── Pods/
├── Podfile
├── Podfile.lock
├── docs/
├── CHANGELOG.md
└── README.md
```

## 6. 说明 / Notes

- SDK 的扫描类型区分 Beacon、Sensor 和 Setting，应用应根据业务选择对应类型。
- 扫描、配置、传感器解析和 OTA 需要匹配的设备、模块和固件。
- SDK 接口 PDF 与当前头文件可能来自不同修订，调用方法签名时请核对当前头文件。
