# react-native-framework

This project builds a XCFramework containing the React Native runtime. This is used to embed React Native modules (UI components and business logic) in an existing native app.

React Native can also be embedded in an existing app thanks to CocoaPods. However, if for some reason you do not want or cannot use CocoaPods, here is an alternative. The XCFramework can be included manually in the Xcode project or be wrapped in a Swift Package.