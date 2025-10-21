import SwiftUI

struct AppGridBackgroundView: View {
    var body: some View {
        Color.white
            .ignoresSafeArea()
            .overlay {
                Canvas { context, size in
                    let color = Color(.sRGB, red: 71/255, green: 85/255, blue: 105/255, opacity: 0.3)
                    let spacing: CGFloat = 32
                    for x in stride(from: 0, through: size.width, by: spacing) {
                        var line = Path()
                        line.move(to: CGPoint(x: x, y: 0))
                        line.addLine(to: CGPoint(x: x, y: size.height))
                        context.stroke(line, with: .color(color), lineWidth: 1)
                    }
                    for y in stride(from: 0, through: size.height, by: spacing) {
                        var line = Path()
                        line.move(to: CGPoint(x: 0, y: y))
                        line.addLine(to: CGPoint(x: size.width, y: y))
                        context.stroke(line, with: .color(color), lineWidth: 1)
                    }
                }
                .blendMode(.normal)
            }
            .overlay {
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.purple.opacity(0.25), location: 0.0),
                        .init(color: Color.purple.opacity(0.1), location: 0.4),
                        .init(color: .clear, location: 0.8)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 400
                )
                .ignoresSafeArea()
            }
    }
}
