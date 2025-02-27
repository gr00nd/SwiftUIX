//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public enum _SwiftUI_TargetPlatform {
    public enum iOS {
        case iOS
    }
    
    public enum macOS {
        case macOS
    }
    
    public enum tvOS {
        case tvOS
    }
    
    public enum watchOS {
        case watchOS
    }
}

public enum _TargetPlatformSpecific<Platform> {
    
}

extension _TargetPlatformSpecific where Platform == _SwiftUI_TargetPlatform.iOS {
    public enum NavigationBarItemTitleDisplayMode {
        case automatic
        case inline
        case large
    }
}

public struct _TargetPlatformConditionalModifiable<Root, Platform> {
    public typealias SpecificTypes = _TargetPlatformSpecific<_SwiftUI_TargetPlatform.iOS>
    
    public let root: Root
    
    fileprivate init(root: Root)  {
        self.root = root
    }

    public var body: Root {
        root
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension _TargetPlatformConditionalModifiable: Scene where Root: Scene {
    fileprivate init(@SceneBuilder root: () -> Root)  {
        self.init(root: root())
    }
}

extension _TargetPlatformConditionalModifiable: View where Root: View {
    fileprivate init(@ViewBuilder root: () -> Root)  {
        self.init(root: root())
    }
}

@available(macOS 13.0, iOS 14.0, watchOS 8.0, tvOS 14.0, *)
extension Scene {
    public func modify<Modified: Scene>(
        for platform: _SwiftUI_TargetPlatform.iOS,
        @SceneBuilder modify: (_TargetPlatformConditionalModifiable<Self, _SwiftUI_TargetPlatform.macOS>) -> Modified
    ) -> some Scene {
        modify(.init(root: self))
    }

    public func modify<Modified: Scene>(
        for platform: _SwiftUI_TargetPlatform.macOS,
        @SceneBuilder modify: (_TargetPlatformConditionalModifiable<Self, _SwiftUI_TargetPlatform.macOS>) -> Modified
    ) -> some Scene {
        modify(.init(root: self))
    }
}

extension View {
    public func modify<Modified: View>(
        for platform: _SwiftUI_TargetPlatform.iOS,
        @ViewBuilder modify: (_TargetPlatformConditionalModifiable<Self, _SwiftUI_TargetPlatform.iOS>) -> Modified
    ) -> some View {
        modify(.init(root: self))
    }
    
    public func modify<Modified: View>(
        for platform: _SwiftUI_TargetPlatform.macOS,
        @ViewBuilder modify: (_TargetPlatformConditionalModifiable<Self, _SwiftUI_TargetPlatform.macOS>) -> Modified
    ) -> some View {
        modify(.init(root: self))
    }
}

@available(macOS 13.0, iOS 14.0, watchOS 8.0, tvOS 14.0, *)
extension _TargetPlatformConditionalModifiable where Root: Scene, Platform == _SwiftUI_TargetPlatform.macOS {
    @SceneBuilder
    public func defaultSize(width: CGFloat, height: CGFloat) -> some Scene {
#if os(macOS)
        root.defaultSize(width: width, height: height)
#else
        root
#endif
    }
}

@available(macOS 11.0, iOS 14.0, watchOS 8.0, tvOS 14.0, *)
extension _TargetPlatformConditionalModifiable where Root: View, Platform == _SwiftUI_TargetPlatform.iOS {
    @ViewBuilder
    public func navigationBarTitleDisplayMode(
        _ mode: SpecificTypes.NavigationBarItemTitleDisplayMode
    ) -> _TargetPlatformConditionalModifiable<some View, Platform> {
#if os(iOS)
        _TargetPlatformConditionalModifiable<_, Platform> {
            switch mode {
                case .automatic:
                    root.navigationBarTitleDisplayMode(.automatic)
                case .inline:
                    root.navigationBarTitleDisplayMode(.inline)
                case .large:
                    root.navigationBarTitleDisplayMode(.inline)
            }
        }
#else
        self
#endif
    }
}

@available(macOS 13.0, iOS 14.0, watchOS 8.0, tvOS 14.0, *)
extension _TargetPlatformConditionalModifiable where Root: View, Platform == _SwiftUI_TargetPlatform.macOS {
    @ViewBuilder
    public func onExitCommand(perform action: (() -> Void)?) -> some View {
#if os(macOS)
        root.onExitCommand(perform: action)
#else
        root
#endif
    }
}

@available(macOS 13.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension _TargetPlatformConditionalModifiable where Root: View, Platform == _SwiftUI_TargetPlatform.macOS {
    @ViewBuilder
    public func controlActiveState(_ state: _SwiftUI_TargetPlatform.macOS._ControlActiveState) -> _TargetPlatformConditionalModifiable<some View, Platform> {
        #if os(macOS)
        _TargetPlatformConditionalModifiable<_, Platform> {
            self.environment(\.controlActiveState, .init(state))
        }
        #else
        _TargetPlatformConditionalModifiable<_, Platform> {
            self
        }
        #endif
    }
}

// MARK: - Auxiliary

extension _SwiftUI_TargetPlatform.macOS {
    public enum _ControlActiveState {
        case key
        case active
        case inactive
    }
}

#if os(macOS)
extension SwiftUI.ControlActiveState {
    public init(_ state: _SwiftUI_TargetPlatform.macOS._ControlActiveState) {
        switch state {
            case .key:
                self = .key
            case .active:
                self = .active
            case .inactive:
                self = .inactive
        }
    }
}

extension _SwiftUI_TargetPlatform.macOS._ControlActiveState {
    public init(_ state: SwiftUI.ControlActiveState) {
        switch state {
            case .key:
                self = .key
            case .active:
                self = .active
            case .inactive:
                self = .inactive
            default:
                assertionFailure()
                
                self = .inactive
        }
    }
}

extension EnvironmentValues {
    public var _SwiftUIX_controlActiveState: _SwiftUI_TargetPlatform.macOS._ControlActiveState {
        get {
            .init(controlActiveState)
        } set {
            controlActiveState = .init(newValue)
        }
    }
}
#else
extension EnvironmentValues {
    public var _SwiftUIX_controlActiveState: _SwiftUI_TargetPlatform.macOS._ControlActiveState {
        get {
            .active
        } set {
            // no op
        }
    }
}
#endif
