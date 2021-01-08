# Toasty
A toast framework writen in swift for iOS with very simple interface.


# Features
- One toast is an `Operation` object, `ToastCenter` manages all toast with an operation queue.
- simple interface.
- Customizable
- UIAccessibility: VoiceOver support.


# Installation

iOS 9 +

### CocoaPods

```
pod 'Toasty'
```

# Getting Started

```
Toast(text: "hello toasty." ,position: .center, superView: self.view).show()

or

self.view.makeToast(text: "hello toasty.",position: .top)
```

You can remove all toasts:
```
ToastCenter.default.cancelAll()
```

Or cancel a toast:
```
Toast(text: "hello toasty." ,position: .center, superView: self.view).cancel()

```

# Accessibility

By default, VoiceOver with UIAccessibility is enabled. To disable it:
```
ToastCenter.default.supportVisionAccessibility = false
```

# License

See LICENSE file for more info.
