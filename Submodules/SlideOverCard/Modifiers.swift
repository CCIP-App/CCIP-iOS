import SwiftUI

extension View {
    public func slideOverCard<Content: View>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, options: SOCOptions = [], backgroundColor: Color = Color(.systemGray6), @ViewBuilder content: @escaping () -> Content) -> some View {
        return ZStack {
            self
            SlideOverCard(
                isPresented: isPresented,
                onDismiss: onDismiss,
                options: options,
                backgroundColor: backgroundColor
            ) { content() }
        }
    }
    
    public func slideOverCard<Item: Identifiable, Content: View>(item: Binding<Item?>, onDismiss: (() -> Void)? = nil, options: SOCOptions = [], backgroundColor: Color = Color(.systemGray6), @ViewBuilder content: @escaping (Item) -> Content) -> some View {
        let binding = Binding(get: { item.wrappedValue != nil }, set: { if !$0 { item.wrappedValue = nil } })
        return self.slideOverCard(isPresented: binding, onDismiss: onDismiss, options: options, backgroundColor: backgroundColor, content: {
            if let item = item.wrappedValue {
                content(item)
            }
        })
    }
}
