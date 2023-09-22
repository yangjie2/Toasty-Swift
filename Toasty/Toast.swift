//
//  Toast.swift
//  Toasty
//
//  Created by yangjie on 2020/12/31.
//

import UIKit
import Foundation

public class ToastCenter : NSObject {
    
    @objc
    public static let `defaultCenter` = ToastCenter()
    
    /**
     If this value is `true` and the user is using VoiceOver,
     VoiceOver will announce the text in the toast when `ToastView` is displayed.
    */
    @objc
    public var supportVisionAccessibility: Bool = true
    
    /**
     Enables or disables queueing behavior for toast views. When `true`,
     toast views will appear one after the other. When `false`,
     only the last requested toast will be shown. Default is `false`.
     */
    @objc
    public var isQueueEnabled = false
    
    
    
    private let queue: OperationQueue = {
       let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private override init() {}
    
    /**
     cancel all toast in queue
     */
    @objc
    public func cancelAll() {
        queue.cancelAllOperations()
    }
    
    
    fileprivate func add(toast: Toast) {
        if !isQueueEnabled {
            cancelAll();
        }
        queue.addOperation(toast)
    }
}

// MARK: - ToastPosition
@objc
public enum ToastPosition: Int {
    case top
    case center
    case bottom
}


// MARK: - Toast Style
public class ToastStyle : NSObject {

    @objc
    public static let `defaultStyle` = ToastStyle()
    
    public override init() {}
    
    /**
     The background color. Default is `white 0` at 70% opacity.
    */
    @objc
    public var backgroundColor: UIColor = UIColor(white: 0, alpha: 0.7)
    
    /**
     The text color. Default is `.white`.
    */
    @objc
    public var textColor: UIColor = .white
    
    /**
     The text font. Default is `.systemFont(ofSize: 14.0)`.
    */
    @objc
    public var textFont: UIFont = .systemFont(ofSize: 14)
    
    /**
     A ratio value from 0.0 to 1.0, representing the maximum width of the toast
     view relative to it's superview. Default is 0.7 (70% of the superview's width).
    */
    @objc
    public var maxWidthRatio: CGFloat = 0.7 {
        didSet {
            maxWidthRatio = max(min(maxWidthRatio, 1.0), 0.0)
        }
    }
    
    /**
     The inset of the text.
     */
    @objc
    public var textInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    
    /**
     The corner radius. Default is 5.0.
    */
    @objc
    public var cornerRadius: CGFloat = 5.0;
    
    /**
     The text alignment. Default is `NSTextAlignment.center`.
    */
    @objc
    public var textAlignment: NSTextAlignment = .center
    
    /**
     Enable or disable a shadow on the toast view. Default is `false`.
    */
    @objc
    public var displayShadow = false
    
    /**
     The shadow color. Default is `.black`.
     */
    @objc
    public var shadowColor: UIColor = .black
    
    /**
     A value from 0.0 to 1.0, representing the opacity of the shadow.
     Default is 0.7 (70% opacity).
    */
    @objc
    public var shadowOpacity: Float = 0.7 {
        didSet {
            shadowOpacity = max(min(shadowOpacity, 1.0), 0.0)
        }
    }

    /**
     The shadow radius. Default is 5.0
    */
    @objc
    public var shadowRadius: CGFloat = 5.0
    
    /**
     The shadow offset. The default is 4 x 4.
    */
    @objc
    public var shadowOffset = CGSize(width: 4.0, height: 4.0)
    
    /**
     vision accessibility
     */
    @objc
    public var supportVisionAccessibility: Bool = true
}


/**
  toast operation
 */
@objc
public class Toast : Operation {
    
    /**
     The duration toast show. Default is 2.5.
     */
    @objc
    public var duration: TimeInterval
    
    /**
     define the look for toast view
     */
    @objc
    public var style: ToastStyle
    
    /**
     define the position of toast view.
     Default is `.bottom`.
     */
    @objc
    public var position: ToastPosition
    
    /**
     text to show
     */
    @objc
    public var text:String
    
    
    private var toastView: UIView?
    private weak var superView: UIView?
    
    //
    private var _executing = false
    override open var isExecuting: Bool {
      get {
        return self._executing
      }
      set {
        self.willChangeValue(forKey: "isExecuting")
        self._executing = newValue
        self.didChangeValue(forKey: "isExecuting")
      }
    }

    private var _finished = false
    override open var isFinished: Bool {
      get {
        return self._finished
      }
      set {
        self.willChangeValue(forKey: "isFinished")
        self._finished = newValue
        self.didChangeValue(forKey: "isFinished")
      }
    }
    
    
    
    //MARK: Initializing
    @objc
    public init(text: String, position: ToastPosition = .bottom, duration: TimeInterval = 2.5, superView: UIView?, style: ToastStyle = ToastStyle()) {
        self.text = text
        self.position = position
        self.duration = duration
        self.superView = superView
        self.style = style
        super.init()
    }
    @objc
    public func show() {
        ToastCenter.defaultCenter.add(toast: self)
    }
    @objc
    public override func cancel() {
        super.cancel()
        finish()
        self.toastView?.removeFromSuperview()
    }
    
    
    
    //MARK: Override
    @objc
    public override func start() {
        let isRunnable = !self.isFinished && !self.isCancelled && !self.isExecuting
        if !isRunnable {
            return
        }
        self.main()
    }
    @objc
    public override func main() {
        self.isExecuting = true
        if text.isEmpty {
            return
        }
        performInMainThread {
            guard let toastview = self.createToastView(), let superview = self.superView else {
                return
            }
            self.toastView = toastview
            superview.addSubview(toastview)
            let point = self.centerPoint(toastSize: toastview.frame.size, superview: superview)
            toastview.center = point
            toastview.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState) {
                toastview.alpha = 1
            } completion: { (completed) in
                if self.style.supportVisionAccessibility {
                    #if swift(>=4.2)
                    UIAccessibility.post(notification: .announcement, argument: self.text)
                    #else
                    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.text)
                    #endif
                }
                UIView.animate(withDuration: self.duration) {
                    toastview.alpha = 1.0001
                } completion: { (completed) in
                    self.finish()
                    UIView.animate(withDuration: 0.3) {
                        toastview.alpha = 0
                    } completion: { (completed) in
                        toastview.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    
    
    //MARK: private
    private func createToastView() -> UIView? {
        guard let superRect = superView?.bounds else {
            return nil
        }
        let view = UIView()
        
        view.backgroundColor = style.backgroundColor
        view.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        view.layer.cornerRadius = style.cornerRadius
        if style.displayShadow {
            view.layer.shadowColor = style.shadowColor.cgColor
            view.layer.shadowOpacity = style.shadowOpacity
            view.layer.shadowOffset = style.shadowOffset
            view.layer.shadowRadius = style.shadowRadius
        }
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.numberOfLines = 0
        textLabel.font = style.textFont
        textLabel.textAlignment = style.textAlignment
        textLabel.lineBreakMode = .byTruncatingTail
        textLabel.textColor = style.textColor
        textLabel.backgroundColor = .clear
        let textSize = textLabel.sizeThatFits(CGSize(width: superRect.size.width*style.maxWidthRatio, height: superRect.size.height*style.maxWidthRatio));
        view.frame = CGRect(x: 0, y: 0, width: textSize.width + style.textInsets.left + style.textInsets.right, height: textSize.height + style.textInsets.top + style.textInsets.bottom)
        view.addSubview(textLabel)
        textLabel.frame = CGRect(x: style.textInsets.left, y: style.textInsets.top, width: textSize.width, height: textSize.height)
        return view
    }
    
    private func centerPoint(toastSize: CGSize, superview: UIView) -> CGPoint {
        let topPadding: CGFloat = style.textInsets.top + superview.toasty_safeAreaInsets.top
        let bottomPadding: CGFloat = style.textInsets.bottom + superview.toasty_safeAreaInsets.bottom
        
        switch position {
        case .top:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: (toastSize.height / 2.0) + topPadding)
        case .center:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: superview.bounds.size.height / 2.0)
        case .bottom:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: (superview.bounds.size.height - (toastSize.height / 2.0)) - bottomPadding)
        }
    }
    
    private func performInMainThread(execute:@escaping () -> Void) {
        if Thread.isMainThread {
            execute()
        }else {
            DispatchQueue.main.async {
                execute()
            }
        }
    }
    
    private func finish() {
      self.isExecuting = false
      self.isFinished = true
    }
    
}


/**
 UIView Extention
 */
@objc
public extension UIView {
    fileprivate var toasty_safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }
    
    /**
     show toast on the view
     */
    func makeToast(text: String, position: ToastPosition = .bottom, duration: TimeInterval = 2.5, style: ToastStyle? = nil) {
        if let sty = style {
            Toast(text: text, position: position, duration: duration, superView: self, style: sty).show()
        }else {
            Toast(text: text, position: position, duration: duration, superView: self, style: ToastStyle.defaultStyle).show()
        }
    }
}
