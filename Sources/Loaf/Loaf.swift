//
//  Loaf.swift
//  Loaf
//
//  Created by Mat Schmid on 2019-02-04.
//  Copyright © 2019 Mat Schmid. All rights reserved.
//

import UIKit
import Dispatch

final public class Loaf {
    
    // MARK: - Specifiers
    
    /// Define a custom style for the loaf.
    public struct Style {
        /// Specifies the background of the Loaf.
        ///
        /// - color(UIColor): Adds a background view with the color property.
        /// - view(UIView): Adds the view as background view.
        /// - visualEffect(UIVisualEffect): Adds a background UIVisualEffectView configured with the UIVisualEffect.
        public enum Background {
            case color(UIColor)
            case view(UIView)
            case visualEffect(UIVisualEffect)
        }
        
        /// Specifies the position of the icon on the loaf. (Default is `.left`)
        ///
        /// - left: The icon will be on the leading side
        /// - right: The icon will be on the trailing side
        public enum IconAlignment {
            case leading
            case trailing
        }
        
        /// Specifies the shape of the loaf.
        ///
        /// - rectangle: The rectange shape.
        ///     - cornerRadius: The corner radius of the rectangle.
        /// - capsule:  A rectangle with corner radius to its height / 2.
        public enum Shape {
            case rectangle(cornerRaidus: CGFloat)
            case capsule
            
            func apply(to view: UIView) {
                switch self {
                case .rectangle(cornerRaidus: let radius):
                    view.layer.cornerRadius = radius
                case .capsule:
                    view.layer.cornerRadius = view.bounds.height * 0.5
                }
                view.layer.masksToBounds = true
            }
        }
        
        /// Specifies the stroke (border) of the Loaf. (Default is `nil`)
        ///
        /// - thickness: The width of the stroke.
        /// - color: The color of the stroke.
        public struct Stroke {
            let thickness: CGFloat
            let color: UIColor
            
            public init(thickness: CGFloat, color: UIColor) {
                self.thickness = thickness
                self.color = color
            }
        }
        
        /// Specifies the shadow of the Loaf. (Default is `nil`)
        ///
        /// - color: The color of the shadow. (Default is `.black`)
        /// - opacity: The offset of the shadow. (Default is `0.3`)
        /// - radius: The radius of the shadow. (Default is `5.0`)
        /// - offset: The offset of the shadow. (Default is `(0 , 1)`)
        public struct Shadow {
            let color: UIColor
            let opacity: CGFloat
            let radius: CGFloat
            let offset: CGPoint
            
            public init(color: UIColor = .black, opacity: CGFloat = 0.3, radius: CGFloat = 5.0, offset: CGPoint = CGPoint(x: 0, y: 1)) {
                self.color = color
                self.opacity = opacity
                self.radius = radius
                self.offset = offset
            }
        }
        
        /// Specifies the width of the Loaf. (Default is `.fixed(280)`)
        ///
        /// - fixed: Specified as pixel size. i.e. 280
        /// - screenPercentage: Specified as a ratio to the screen size. This value must be between 0 and 1. i.e. 0.8
        public enum Width {
            case fixed(CGFloat)
            case screenPercentage(CGFloat)
            case fittingText(maxTextWidth: CGFloat)
        }
        
        /// The background color of the loaf.
        let background: Background
        
        /// The shape of the loaf.
        let shape: Shape
        
        /// The stroke (border) of the loaf.
        let stroke: Stroke?
        
        /// The shadow of the loaf.
        let shadow: Shadow?
        
        /// The color of the label's text
        let textColor: UIColor
        
        /// The color of the icon (Assuming it's rendered as template)
        let tintColor: UIColor
        
        /// The font of the label
        let font: UIFont
        
        /// The icon on the loaf
        let icon: UIImage?
        
        /// The alignment of the text within the Loaf
        let textAlignment: NSTextAlignment
        
        /// The position of the icon
        let iconAlignment: IconAlignment
		
        /// The width of the loaf
        let width: Width
        
        /// The edge insets of the loaf
        let layoutMargins: NSDirectionalEdgeInsets
		
        public init(
            background: Background,
            shape: Shape = .rectangle(cornerRaidus: 6),
            stroke: Stroke? = nil,
            shadow: Shadow? = nil,
            textColor: UIColor = .white,
            tintColor: UIColor = .white,
            font: UIFont = .systemFont(ofSize: 14, weight: .medium),
            icon: UIImage? = Icon.info,
            textAlignment: NSTextAlignment = .natural,
            iconAlignment: IconAlignment = .leading,
            width: Width = .fixed(280),
            layoutMargins: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)) {
                self.background = background
                self.shape = shape
                self.stroke = stroke
                self.shadow = shadow
                self.textColor = textColor
                self.tintColor = tintColor
                self.font = font
                self.icon = icon
                self.textAlignment = textAlignment
                self.iconAlignment = iconAlignment
                self.width = width
                self.layoutMargins = layoutMargins
        }
    }
    
    /// Defines the loaf's status. (Default is `.info`)
    ///
    /// - success: Represents a success message
    /// - error: Represents an error message
    /// - warning: Represents a warning message
    /// - info: Represents an info message
    /// - custom: Represents a custom loaf with a specified style.
    public enum State {
        case success
        case error
        case warning
        case info
        case custom(Style)
        
        var style: Style {
            let background: Style.Background
            var image: UIImage
            switch self {
            case .success:
                image = Loaf.Icon.success
                background = .color(UIColor(hexString: "#2ecc71"))
            case .warning:
                image = Loaf.Icon.warning
                background = .color(UIColor(hexString: "##f1c40f"))
            case .error:
                image = Loaf.Icon.error
                background = .color(UIColor(hexString: "##e74c3c"))
            case .info:
                image = Loaf.Icon.info
                background = .color(UIColor(hexString: "##34495e"))
            case .custom(let style):
                return style
            }
            
            return Style(background: background, icon: image)
        }
    }
    
    /// Defines the loaction to display the loaf. (Default is `.bottom`)
    ///
    /// - top: Top of the display
    /// - bottom: Bottom of the display
    public enum Location {
        case top
        case bottom
    }
    
    /// Defines the layout area to display the loaf. (Default is `.currentContext`)
    /// - currentContext: Loaf is presented inside the safe area of the view controller which `definesPresentationContext = true`
    /// - sender: Loaf is presented inside `sender`'s view safe area.
    public enum LayoutReference {
        case currentContext
        case sender
    }
    
    /// Defines either the presenting or dismissing direction of loaf. (Default is `.vertical`)
    ///
    /// - left: To / from the left
    /// - right: To / from the right
    /// - vertical: To / from the top or bottom (depending on the location of the loaf)
    public enum Direction {
        case left
        case right
        case vertical
    }
    
    /// Defines the duration of the loaf presentation. (Default is .`avergae`)
    ///
    /// - short: 2 seconds
    /// - average: 4 seconds
    /// - long: 8 seconds
    /// - custom: A custom duration (usage: `.custom(5.0)`)
    public enum Duration {
        case short
        case average
        case long
        case custom(TimeInterval)
        
        var length: TimeInterval {
            switch self {
            case .short:   return 2.0
            case .average: return 4.0
            case .long:    return 8.0
            case .custom(let timeInterval):
                return timeInterval
            }
        }
    }
    
    /// Icons used in basic states
    public enum Icon {
        public static let success = Icons.imageOfSuccess().withRenderingMode(.alwaysTemplate)
        public static let error = Icons.imageOfError().withRenderingMode(.alwaysTemplate)
        public static let warning = Icons.imageOfWarning().withRenderingMode(.alwaysTemplate)
        public static let info = Icons.imageOfInfo().withRenderingMode(.alwaysTemplate)
    }
    
    // Reason a Loaf was dismissed
    public enum DismissalReason {
        case tapped
        case timedOut
        case programmatically
        case dropped(String)
    }
    
    // MARK: - Properties
    public typealias LoafCompletionHandler = ((DismissalReason) -> Void)?
    var message: String
    var state: State
    var location: Location
    var layoutReference: LayoutReference
    var duration: Duration = .average
    var presentingDirection: Direction
    var dismissingDirection: Direction
    var completionHandler: LoafCompletionHandler = nil
    fileprivate var dismissalReason: DismissalReason = .programmatically
    
    weak var sender: UIViewController?
    
    // MARK: - Public methods
    public init(_ message: String,
                state: State = .info,
                location: Location = .bottom,
                layoutReference: LayoutReference = .currentContext,
                presentingDirection: Direction = .vertical,
                dismissingDirection: Direction = .vertical,
                sender: UIViewController) {
        self.message = message
        self.state = state
        self.location = location
        self.layoutReference = layoutReference
        self.presentingDirection = presentingDirection
        self.dismissingDirection = dismissingDirection
        self.sender = sender
    }
    
    /// Show the loaf for a specified duration. (Default is `.average`)
    ///
    /// - Parameter duration: Length the loaf will be presented
    public func show(_ duration: Duration = .average, completionHandler: LoafCompletionHandler = nil) {
        self.duration = duration
        self.completionHandler = completionHandler
        LoafManager.shared.queueAndPresent(self)
    }
	
	/// Manually dismiss a currently presented Loaf
	///
	/// - Parameter animated: Whether the dismissal will be animated
	public static func dismiss(sender: UIViewController, animated: Bool = true){
		guard LoafManager.shared.isPresenting else { return }
		guard let vc = sender.presentedViewController as? LoafViewController else { return }
        vc.loaf.dismissalReason = .programmatically
		vc.dismiss(animated: animated)
	}
}

final fileprivate class LoafManager: LoafDelegate {
    static let shared = LoafManager()
    
    fileprivate var queue = Queue<Loaf>()
    fileprivate var isPresenting = false
    
    fileprivate func queueAndPresent(_ loaf: Loaf) {
        queue.enqueue(loaf)
        presentIfPossible()
    }
    
    func loafDidDismiss() {
        isPresenting = false
        presentIfPossible()
    }
    
    fileprivate func presentIfPossible() {
        guard isPresenting == false else {
            return
        }
        
        guard let loaf = queue.dequeue() else {
            return
        }
        
        guard let sender = loaf.sender else {
            loaf.completionHandler?(.dropped("Sender dealloced!"))
            presentIfPossible()
            return
        }
        
        guard sender.view.window != nil else {
            loaf.completionHandler?(.dropped("Sender detached!"))
            presentIfPossible()
            return
        }
        
        isPresenting = true
        let loafVC = LoafViewController(loaf)
        loafVC.delegate = self
        sender.present(loafVC, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + loaf.duration.length, execute: { [weak loafVC] in
            guard let loafVC = loafVC else {
                return
            }
            loaf.dismissalReason = .timedOut
            loafVC.dismiss(animated: true)
        })
    }
}

protocol LoafDelegate: AnyObject {
    func loafDidDismiss()
}

final class LoafViewController: UIViewController {
    var loaf: Loaf
    
    var backgroundView: UIView!
    let label = UILabel()
    let imageView = UIImageView(image: nil)
    let stackView = UIStackView()
    
    var transDelegate: UIViewControllerTransitioningDelegate
    weak var delegate: LoafDelegate?
    
    init(_ toast: Loaf) {
        self.loaf = toast
        self.transDelegate = Manager(loaf: toast)
        super.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = self.transDelegate
        self.modalPresentationStyle = .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let style = loaf.state.style
        
        label.text = loaf.message
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = style.textColor
        label.font = style.font
        label.textAlignment = style.textAlignment
        
        imageView.tintColor = style.tintColor
        imageView.contentMode = .scaleAspectFit
        imageView.image = style.icon
        imageView.isHidden = (imageView.image == nil)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = style.layoutMargins
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.alignment = .center
        
        if style.iconAlignment == .leading {
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(label)
        } else {
            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(imageView)
        }
                
        switch style.background {
        case .color(let color):
            backgroundView = UIView()
            backgroundView.backgroundColor = color
            view.addSubview(backgroundView)
            view.addSubview(stackView)
        case .view(let customView):
            backgroundView = customView
            view.addSubview(backgroundView)
            view.addSubview(stackView)
        case .visualEffect(let visualEffect):
            let effectView = UIVisualEffectView(effect: visualEffect)
            effectView.contentView.addSubview(stackView)
            backgroundView = effectView
            view.addSubview(backgroundView)
        }
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        if let stroke = style.stroke {
            backgroundView.layer.borderWidth = stroke.thickness
            backgroundView.layer.borderColor = stroke.color.cgColor
        }
        
        if let shadow = style.shadow {
            view.layer.shadowColor = shadow.color.cgColor
            view.layer.shadowOpacity = Float(shadow.opacity)
            view.layer.shadowRadius = shadow.radius
            view.layer.shadowOffset = CGSize(width: shadow.offset.x, height: shadow.offset.y)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        constraintViews()
        updatePreferredContentSize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loaf.state.style.shape.apply(to: backgroundView)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) { [weak self] in
            guard let self = self else { return }
            completion?()
            loaf.completionHandler?(loaf.dismissalReason)
            delegate?.loafDidDismiss()
        }
    }
    
    private func updatePreferredContentSize() {
        var width: CGFloat = 280
        var fittingPriority: UILayoutPriority = .required
        
        switch loaf.state.style.width {
        case .fixed(let value):
            width = value
            fittingPriority = .required
        case .screenPercentage(let percentage):
            guard 0...1 ~= percentage else { return }
            width = UIScreen.main.bounds.width * percentage
            fittingPriority = .required
        case .fittingText(let maxTextWidth):
            label.preferredMaxLayoutWidth = maxTextWidth
            fittingPriority = .fittingSizeLevel
            width = .greatestFiniteMagnitude
        }
        
        let fittingSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        preferredContentSize = view.systemLayoutSizeFitting(fittingSize,
                                                            withHorizontalFittingPriority: fittingPriority,
                                                            verticalFittingPriority: .fittingSizeLevel)
    }
    
    @objc private func handleTap() {
        loaf.dismissalReason = .tapped
        dismiss(animated: true)
    }
    
    private func constraintViews() {
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 28),
            imageView.widthAnchor.constraint(equalToConstant: 28),
        ])
        
        let stackSuperView = stackView.superview!
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: stackSuperView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: stackSuperView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: stackSuperView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: stackSuperView.bottomAnchor)
        ])
    }
}

private struct Queue<T> {
    fileprivate var array = [T]()
    
    mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    mutating func dequeue() -> T? {
        if array.isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
}

