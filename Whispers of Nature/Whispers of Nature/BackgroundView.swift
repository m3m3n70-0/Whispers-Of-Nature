import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.0)).edgesIgnoringSafeArea(.all) // #131313
            VStack {
                RadialGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.09, green: 0.47, blue: 0.33, alpha: 0.3)), Color.clear]),
                               center: .topLeading, startRadius: 100, endRadius: 400) // #167853 with opacity
                    .offset(x: -100, y: -100)
                    .blur(radius: 50)
                Spacer()
                RadialGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.14, green: 0.28, blue: 0.24, alpha: 0.3)), Color.clear]),
                               center: .center, startRadius: 50, endRadius: 300) // #24473c with opacity
                    .offset(x: 100, y: 100)
                    .blur(radius: 70)
                Spacer()
                RadialGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.09, green: 0.47, blue: 0.33, alpha: 0.3)), Color.clear]),
                               center: .bottomTrailing, startRadius: 100, endRadius: 400) // #167853 with opacity
                    .offset(x: 50, y: 50)
                    .blur(radius: 50)
            }
        }
    }
}
