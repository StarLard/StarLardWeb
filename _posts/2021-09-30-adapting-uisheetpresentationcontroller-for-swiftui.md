---
layout: single
title:  "Adapting UISheetPresentationController for SwiftUI"
date:   2021-09-30 16:05:45 -0800
categories: iOS
tags: swift swiftui uikit ios apple
---
[UISheetPresentationController](https://developer.apple.com/documentation/uikit/uisheetpresentationcontroller) was recently released for iOS 15 and finally gives us a 1st party component for the Apple map style bottom-sheet seen in many apps. Unfortunately, iOS 15 does not ship with an equivalent component for SwiftUI, but with a little [UIViewControllerRepresentable](https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable) magic, we can get it working in SwiftUI:

![uisheetpresentationcontroller_demo.gif](/assets/images/uisheetpresentationcontroller_demo.gif){: .align-center}

This approach works by creating wrapping our SwiftUI views in [UIHostingController](https://developer.apple.com/documentation/swiftui/uihostingcontroller) instances, which can leverage the new [UISheetPresentationController](https://developer.apple.com/documentation/uikit/uisheetpresentationcontroller) APIs. The hosting controllers are subclassed so that we can capture the presentation and dismissal events to keep the SwiftUI bindings up-to-date with the state of the view. We then take the wrapped the controllers in return them in a [UIViewControllerRepresentable](https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable) SwiftUI view. Finally, we bundle the whole package up into a view modifier to give us a SwiftUI-style API for creating our new sheet. The full source code can be viewed here:

<script src="https://gist.github.com/StarLard/5662feeb0b2762e6519e83fa6555fb0d.js"></script>