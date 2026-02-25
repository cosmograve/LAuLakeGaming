import SwiftUI

struct StartScreenBackground: View {
    let imageName: String

    init(imageName: String = "StartScreen") {
        self.imageName = imageName
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#2C2A77"),
                    Color(hex: "#0A063D"),
                    Color(hex: "#040026")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(imageName)
                .resizable()
                .scaledToFill()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .ignoresSafeArea()
    }
}
