import SwiftUI

struct PrimaryButton: View {
    enum Size { case small, medium, large }
    let title: LocalizedStringKey
    let isLoading: Bool
    let isDisabled: Bool
    let size: Size
    let fullWidth: Bool
    let action: () -> Void

    init(title: LocalizedStringKey,
         isLoading: Bool = false,
         isDisabled: Bool = false,
         size: Size = .medium,
         fullWidth: Bool = true,
         action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.size = size
        self.fullWidth = fullWidth
        self.action = action
    }

    var body: some View {
        Button(action: { if !isLoading { action() } }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                if !isLoading {
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
        }
        .buttonStyle(PrimaryButtonStyle(size: size))
        .disabled(isDisabled || isLoading)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let size: PrimaryButton.Size

    func makeBody(configuration: Configuration) -> some View {
        let fillColor: Color = isEnabled ? Theme.brandPrimary : Theme.brandPrimaryLight
        return configuration.label
            .font(.body)
            .foregroundStyle(Color.white)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(fillColor)
            )
            .opacity(configuration.isPressed && isEnabled ? 0.94 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.995 : 1)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        }
    }
}
