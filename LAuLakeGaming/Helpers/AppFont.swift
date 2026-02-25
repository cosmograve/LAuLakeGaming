import SwiftUI
import UIKit

enum AppFont {
    enum Family {
        static let regular = "Tiny5-Regular"
    }

    enum Weight {
        case regular
    }

    static func tiny(size: CGFloat, weight: Weight) -> Font {
        let name: String
        switch weight {
        case .regular: name = Family.regular
        }

        return Font(uiFont: makeUIFont(name: name, size: size))
    }

    private static func makeUIFont(name: String, size: CGFloat) -> UIFont {
        if let custom = UIFont(name: name, size: size) {
            return custom
        }

        return UIFont.systemFont(ofSize: size, weight: .regular)
    }
}

extension Font {
    init(uiFont: UIFont) {
        self = Font(uiFont as CTFont)
    }
}
