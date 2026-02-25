import SwiftUI

enum MetalSurfaceKind {
    case plate
    case button
}

struct MetalSurface<Content: View>: View {
    let kind: MetalSurfaceKind
    let content: Content

    init(kind: MetalSurfaceKind, @ViewBuilder content: () -> Content) {
        self.kind = kind
        self.content = content()
    }

    private var innerHorizontalInset: CGFloat {
        switch kind {
        case .plate:
            return 20
        case .button:
            return 5
        }
    }

    private var innerVerticalInset: CGFloat {
        switch kind {
        case .plate:
            return 8
        case .button:
            return 5
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#F2F4F8"),
                            Color(hex: "#A0A6B0"),
                            Color(hex: "#454A55"),
                            Color(hex: "#6F7682")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#0C0E12"),
                            Color(hex: "#020202"),
                            Color(hex: "#1A1D24")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(.horizontal, innerHorizontalInset)
                .padding(.vertical, innerVerticalInset)

            content
        }
    }
}
