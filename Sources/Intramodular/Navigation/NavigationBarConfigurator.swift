//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

@usableFromInline
struct NavigationBarConfigurator<Leading: View, Center: View, Trailing: View, LargeTrailing: View>: UIViewControllerRepresentable {
    @usableFromInline
    class UIViewControllerType: UIViewController {
        weak var navigationBarLargeTitleView: UIView? = nil
        
        var navigationBarLargeTitleTrailingItemHostingController: UIHostingController<LargeTrailing>? = nil
        
        var leading: Leading? {
            didSet {
                updateNavigationBar(parent: parent)
            }
        }
        
        var center: Center? {
            didSet {
                updateNavigationBar(parent: parent)
            }
        }
        
        var trailing: Trailing? {
            didSet {
                updateNavigationBar(parent: parent)
            }
        }
        
        var largeTrailing: LargeTrailing? {
            didSet {
                updateNavigationBar(parent: parent)
            }
        }
        
        var displayMode: NavigationBarItem.TitleDisplayMode? {
            didSet {
                updateNavigationBar(parent: parent)
            }
        }
        
        override func willMove(toParent parent: UIViewController?) {
            updateNavigationBar(parent: parent)
            
            super.willMove(toParent: parent)
        }
        
        private func updateNavigationBar(parent: UIViewController?) {
            guard let parent = parent else {
                return
            }
            
            #if os(iOS) || targetEnvironment(macCatalyst)
            if let displayMode = displayMode {
                switch displayMode {
                    case .automatic:
                        parent.navigationItem.largeTitleDisplayMode = .automatic
                    case .inline:
                        parent.navigationItem.largeTitleDisplayMode = .never
                    case .large:
                        parent.navigationItem.largeTitleDisplayMode = .always
                    @unknown default:
                        parent.navigationItem.largeTitleDisplayMode = .automatic
                }
            }
            #endif
            
            if let leading = leading {
                if !(leading is EmptyView) {
                    if parent.navigationItem.leftBarButtonItem == nil {
                        parent.navigationItem.leftBarButtonItem = .init(customView: UIHostingView(rootView: leading))
                    } else if let view = parent.navigationItem.leftBarButtonItem?.customView as? UIHostingView<Leading> {
                        view.rootView = leading
                    } else {
                        parent.navigationItem.leftBarButtonItem?.customView = UIHostingView(rootView: leading)
                    }
                }
            } else {
                parent.navigationItem.leftBarButtonItem = nil
            }
            
            if let center = center {
                if !(center is EmptyView) {
                    if let view = parent.navigationItem.titleView as? UIHostingView<Center> {
                        view.rootView = center
                    } else {
                        parent.navigationItem.titleView = UIHostingView(rootView: center)
                    }
                }
            } else {
                parent.navigationItem.titleView = nil
            }
            
            if let trailing = trailing {
                if !(trailing is EmptyView) {
                    if parent.navigationItem.rightBarButtonItem == nil {
                        parent.navigationItem.rightBarButtonItem = .init(customView: UIHostingView(rootView: trailing))
                    } else if let view = parent.navigationItem.rightBarButtonItem?.customView as? UIHostingView<Trailing> {
                        view.rootView = trailing
                    } else {
                        parent.navigationItem.rightBarButtonItem?.customView = UIHostingView(rootView: trailing)
                    }
                }
            } else {
                parent.navigationItem.rightBarButtonItem = nil
            }
            
            parent.navigationItem.leftBarButtonItem?.customView?.sizeToFit()
            parent.navigationItem.titleView?.sizeToFit()
            parent.navigationItem.rightBarButtonItem?.customView?.sizeToFit()
            
            if let largeTrailing = largeTrailing, !(largeTrailing is EmptyView) {
                guard let navigationBar = self.navigationController?.navigationBar else {
                    return
                }
                
                guard let _UINavigationBarLargeTitleView = NSClassFromString("_" + "UINavigationBar" + "LargeTitleView") else {
                    return
                }
                
                for subview in navigationBar.subviews {
                    if subview.isKind(of: _UINavigationBarLargeTitleView.self) {
                        navigationBarLargeTitleView = subview
                    }
                }
                
                if let navigationBarLargeTitleView = navigationBarLargeTitleView {
                    if let hostingController = navigationBarLargeTitleTrailingItemHostingController, hostingController.view.superview == navigationBarLargeTitleView {
                        hostingController.rootView = largeTrailing
                    } else {
                        let hostingController = UIHostingController(rootView: largeTrailing)
                        
                        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                        
                        navigationBarLargeTitleView.addSubview(hostingController.view)
                        
                        NSLayoutConstraint.activate([
                            hostingController.view.centerYAnchor.constraint(
                                equalTo: navigationBarLargeTitleView.centerYAnchor
                            ),
                            hostingController.view.trailingAnchor.constraint(
                                equalTo: navigationBarLargeTitleView.layoutMarginsGuide.trailingAnchor
                            )
                        ])
                        
                        self.navigationBarLargeTitleTrailingItemHostingController = hostingController
                    }
                }
            }
        }
    }
    
    let leading: Leading
    let center: Center
    let trailing: Trailing
    let largeTrailing: LargeTrailing
    let displayMode: NavigationBarItem.TitleDisplayMode?
    
    @usableFromInline
    init(
        leading: Leading,
        center: Center,
        trailing: Trailing,
        largeTrailing: LargeTrailing,
        displayMode: NavigationBarItem.TitleDisplayMode?
    ) {
        self.leading = leading
        self.center = center
        self.trailing = trailing
        self.largeTrailing = largeTrailing
        self.displayMode = displayMode
    }
    
    @usableFromInline
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init()
    }
    
    @usableFromInline
    func updateUIViewController(_ viewController: UIViewControllerType, context: Context) {
        viewController.displayMode = displayMode
        viewController.leading = leading
        viewController.center = center
        viewController.trailing = trailing
        viewController.largeTrailing = largeTrailing
    }
}

extension View {
    @inlinable
    public func navigationBarItems<Leading: View, Center: View, Trailing: View>(
        leading: Leading,
        center: Center,
        trailing: Trailing,
        displayMode: NavigationBarItem.TitleDisplayMode? = .automatic
    ) -> some View {
        background(
            NavigationBarConfigurator(
                leading: leading,
                center: center,
                trailing: trailing,
                largeTrailing: EmptyView(),
                displayMode: displayMode
            )
        )
    }
    
    @available(tvOS, unavailable)
    @inlinable
    public func navigationBarLargeTitleItems<L>(
        trailing: L,
        displayMode: NavigationBarItem.TitleDisplayMode? = .large
    ) -> some View where L : View {
        background(
            NavigationBarConfigurator(
                leading: EmptyView(),
                center: EmptyView(),
                trailing: EmptyView(),
                largeTrailing: trailing.font(.largeTitle),
                displayMode: displayMode
            )
        )
    }
    
    @inlinable
    public func navigationBarItems<Leading: View, Center: View>(
        leading: Leading,
        center: Center,
        displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    ) -> some View {
        navigationBarItems(leading: leading, center: center, trailing: EmptyView(), displayMode: displayMode)
    }
    
    @inlinable
    public func navigationBarTitleView<V: View>(
        _ center: V,
        displayMode: NavigationBarItem.TitleDisplayMode
    ) -> some View {
        navigationBarItems(leading: EmptyView(), center: center, trailing: EmptyView(), displayMode: displayMode)
    }
    
    @inlinable
    public func navigationBarTitleView<V: View>(
        _ center: V
    ) -> some View {
        navigationBarItems(leading: EmptyView(), center: center, trailing: EmptyView(), displayMode: .automatic)
    }
    
    @inlinable
    public func navigationBarItems<Center: View, Trailing: View>(
        center: Center,
        trailing: Trailing,
        displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    ) -> some View {
        navigationBarItems(leading: EmptyView(), center: center, trailing: trailing, displayMode: displayMode)
    }
}

#endif
