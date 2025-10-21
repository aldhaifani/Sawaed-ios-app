import SwiftUI

enum Theme {
    // Brand Colors
    static let brandPrimary: Color = Color(.displayP3, red: 86/255, green: 83/255, blue: 165/255, opacity: 1)
    static let brandPrimaryLight: Color = Color(.displayP3, red: 160/255, green: 156/255, blue: 220/255, opacity: 1)
    static let brandGradient: LinearGradient = LinearGradient(
        colors: [Color.white, Color.white.opacity(0.96)],
        startPoint: .top,
        endPoint: .bottom
    )

    // Layout
    static let cornerRadius: CGFloat = 16
    static let cardHorizontalPadding: CGFloat = 24
    static let cardInnerPadding: CGFloat = 20

    // Shadows
    static let cardShadowColor: Color = Color.black.opacity(0.08)
    static let cardShadowRadius: CGFloat = 24
    static let cardShadowXY: (x: CGFloat, y: CGFloat) = (0, 8)
}

struct CardContainer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Theme.cardInnerPadding)
            .frame(maxWidth: 480)
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .fill(Theme.brandGradient)
                    .shadow(color: Theme.cardShadowColor, radius: Theme.cardShadowRadius, x: Theme.cardShadowXY.x, y: Theme.cardShadowXY.y)
            )
            .padding(.horizontal, Theme.cardHorizontalPadding)
    }
}

extension View {
    func cardContainer() -> some View { modifier(CardContainer()) }
}
