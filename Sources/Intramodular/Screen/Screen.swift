//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if (os(iOS) && canImport(CoreTelephony)) || os(macOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)

/// A representation of the device's screen.
public class Screen: ObservableObject {
    public static let main = Screen()
    
    public var bounds: CGRect  {
        #if os(iOS) || os(tvOS)
        return UIScreen.main.bounds
        #elseif os(macOS)
        return NSScreen.main?.frame ?? CGRect.zero
        #elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds
        #endif
    }
    
    public var scale: CGFloat {
        #if os(iOS) || os(tvOS)
        return UIScreen.main.scale
        #elseif os(macOS)
        return NSScreen.main?.backingScaleFactor ?? 1.0
        #elseif os(watchOS)
        return WKInterfaceDevice.current().screenScale
        #endif
    }
    
    public var orientation: DeviceOrientation {
        .current
    }
    
    var orientationObserver: NSObjectProtocol?
    
    private init() {
        #if os(iOS)
        orientationObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                self?.objectWillChange.send()
            }
        )
        #endif
    }
    
    deinit {
        orientationObserver.map(NotificationCenter.default.removeObserver(_:))
    }
}

// MARK: - Extensions

extension Screen {
    public var size: CGSize {
        bounds.size
    }
    
    public var width: CGFloat {
        bounds.width
    }
    
    public var height: CGFloat {
        bounds.height
    }
    
    public static var size: CGSize {
        main.size
    }
    
    public static var width: CGFloat {
        main.width
    }
    
    public static var height: CGFloat {
        main.height
    }
    
    public var widthMajorSize: CGSize {
        if width >= height {
            return .init(width: height, height: width)
        } else {
            return .init(width: width, height: height)
        }
    }
}

// MARK: - Conformances

extension Screen: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func == (lhs: Screen, rhs: Screen) -> Bool {
        true // FIXME
    }
}

// MARK: - Auxiliary

@_spi(Internal)
public enum _ScreenOrCoordinateSpace: Hashable {
    case screen(Screen?)
    case coordinateSpace(CoordinateSpace)
}

@_spi(Internal)
public struct _CoordinateSpaceSpecific<T> {
    private var storage: [_ScreenOrCoordinateSpace: T] = [:]
    
    public init() {
        
    }
    
    public subscript(_ key: _ScreenOrCoordinateSpace) -> T? {
        get {
            storage[key]
        } set {
            storage[key] = newValue
        }
    }
}

extension EnvironmentValues {
    public var screen: Screen {
        get {
            self[DefaultEnvironmentKey<Screen>.self] ?? .main
        } set {
            self[DefaultEnvironmentKey<Screen>.self] = newValue
        }
    }
}

#endif
