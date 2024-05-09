import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                RadialGradient(gradient: Gradient(colors: [Color.green.opacity(0.3), Color.clear]),
                               center: .topLeading, startRadius: 100, endRadius: 400)
                    .offset(x: -100, y: -100)
                    .blur(radius: 50)
                Spacer()
                RadialGradient(gradient: Gradient(colors: [Color.green.opacity(0.2), Color.clear]),
                               center: .center, startRadius: 50, endRadius: 300)
                    .offset(x: 100, y: 100)
                    .blur(radius: 70)
                Spacer()
                RadialGradient(gradient: Gradient(colors: [Color.green.opacity(0.2), Color.clear]),
                               center: .bottomTrailing, startRadius: 100, endRadius: 400)
                    .offset(x: 50, y: 50)
                    .blur(radius: 50)
            }
        }
    }
}
