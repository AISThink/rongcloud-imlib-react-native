# react-native-rongcloud-imlib
Rongcloud IMLib Module For React Native


## ios config
add framework
- libopencore-amrnb.a
- RongIMLib.framework
上述两个文件放在工程ios目录下。 在工程YCParApp的Libraries上点右键，将这两个文件加到项目中

- libsqlite3.tbd
Target > YCParApp > BuildPhase > Link Binary With Libraries > + > 输入libsqlite3.tbd


add framework search paths & library search paths
- $(PROJECT_DIR)/../node_modules/react-native-rongcloud-imlib/ios/lib
Target > YCParApp > Build Setting > Search Paths 



## android config
- config AndroidManifest.xml
- fix settings.gradle
```
// file: android/settings.gradle
// ...
include ':react-native-rongcloud-imlib'
project(":react-native-rongcloud-imlib").projectDir = file("../node_modules/react-native-rongcloud-imlib/android")
```
```
// file: android/app/build.gradle

dependencies {
    // ...
    compile project(':react-native-rongcloud-imlib')
}

```

## import
```
import RongCloud from 'react-native-rongcloud-imlib'
```
```

```
