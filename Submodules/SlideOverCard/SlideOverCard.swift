import SwiftUI

public struct SlideOverCard<Content: View>: View {
    var isPresented: Binding<Bool>
    let onDismiss: (() -> Void)?
    var options: SOCOptions
    let content: Content
    let backgroundColor: Color
    
    public init(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, options: SOCOptions = [], backgroundColor: Color = Color(.systemGray6), content: @escaping () -> Content) {
        self.isPresented = isPresented
        self.onDismiss = onDismiss
        self.options = options
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    @GestureState private var viewOffset: CGFloat = 0.0
    
    var isiPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    public var body: some View {
        ZStack {
            if isPresented.wrappedValue {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .zIndex(1)
                    .onTapGesture {
                        dismiss()
                    }
                
                Group {
                    if #available(iOS 14.0, *) {
                        container
                            .ignoresSafeArea(.container, edges: .bottom)
                    } else {
                        container
                            .edgesIgnoringSafeArea(.bottom)
                    }
                }.transition(isiPad ? AnyTransition.opacity.combined(with: .offset(x: 0, y: 200)) : .move(edge: .bottom))
                    .zIndex(2)
            }
        }.animation(.spring(response: 0.35, dampingFraction: 1), value: isPresented.wrappedValue)
    }
    
    private var container: some View {
        VStack {
            Spacer()
            
            if isiPad {
                card.aspectRatio(1.0, contentMode: .fit)
                Spacer()
            } else {
                card
            }
        }
    }
    
    private var card: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if !options.contains(.hideExitButton) {
                Button(action: dismiss) {
                    SOCExitButton()
                }.frame(width: 24, height: 24)
            }
            
            content
                .padding([.horizontal, options.contains(.hideExitButton) ? .vertical : .bottom], 14)
        }.padding(20)
        .background(RoundedRectangle(cornerRadius: 38.5, style: .continuous)
                        .fill(backgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 38.5, style: .continuous))
        .offset(x: 0, y: viewOffset/pow(2, abs(viewOffset)/500+1))
        .gesture(
            options.contains(.disableDrag) ? nil :
                DragGesture()
                .updating($viewOffset) { value, state, transaction in
                    state = value.translation.height
                }
                .onEnded() { value in
                    if value.predictedEndTranslation.height > 175 && !options.contains(.disableDragToDismiss) {
                        dismiss()
                    }
                }
        )
    }
    
    func dismiss() {
        withAnimation {
            isPresented.wrappedValue = false
        }
        if (onDismiss != nil) { onDismiss!() }
    }
}

public struct SOCOptions: OptionSet {
    public let rawValue: Int8
    
    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
    
    public static let disableDrag = SOCOptions(rawValue: 1)
    public static let disableDragToDismiss = SOCOptions(rawValue: 1 << 1)
    public static let hideExitButton = SOCOptions(rawValue: 1 << 2)
}
