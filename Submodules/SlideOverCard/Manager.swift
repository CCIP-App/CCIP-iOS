import SwiftUI

public struct SOCManager {
    private static var viewController: UIViewController? = nil
    
    @available(iOSApplicationExtension, unavailable)
    public static func present<Content:View>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, options: SOCOptions = SOCOptions(), style: UIUserInterfaceStyle = .unspecified, @ViewBuilder content: @escaping () -> Content) {
        let rootCard = SlideOverCard(isPresented: isPresented, onDismiss: {
            dismiss(isPresented: isPresented)
        }, options: options, content: content)
        
        let controller = UIHostingController(rootView: rootCard)
        controller.view.backgroundColor = .clear
        controller.modalPresentationStyle = .overFullScreen
        controller.overrideUserInterfaceStyle = style
        
        self.viewController = UIApplication.getTopViewController()
        self.viewController?.present(controller, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            withAnimation {
                isPresented.wrappedValue = true
            }
        }
    }
    
    @available(iOSApplicationExtension, unavailable)
    public static func dismiss(isPresented: Binding<Bool>) {
        withAnimation {
            isPresented.wrappedValue = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.viewController?.dismiss(animated: false)
            self.viewController = nil
        }
    }
}

private extension UIApplication {
    static func getTopViewController() -> UIViewController? {
        var presentedViewController: UIViewController? = nil
        let currentUIWindow = self.getCurrentUIWindow()
        if var topController = currentUIWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            presentedViewController = topController
        }
        return presentedViewController
    }
    
    static func getCurrentUIWindow() -> UIWindow? {
        let connectedScenes = self.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
    }
}
