import SwiftUI

final class TextSizeViewModel: ObservableObject {
    @Published var textSize: CGSize?

    func didUpdateTextView(_ textView: AttributedTextImpl.TextView) {
        DispatchQueue.main.async {
            self.textSize = textView.intrinsicContentSize
        }
    }
}
