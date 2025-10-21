import SwiftUI
import UIKit

struct AppTextField: View {
    enum Size { case small, medium, large }
    let label: LocalizedStringKey?
    let placeholder: LocalizedStringKey
    @Binding var text: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    let contentType: UITextContentType?
    let submitLabel: SubmitLabel
    let size: Size
    let leadingSystemImage: String?
    let trailingSystemImage: String?
    let error: LocalizedStringKey?
    let onSubmit: () -> Void
    let preventAutoLinkStyling: Bool
    let placeholderKeyForMask: String?

    @State private var isPasswordVisible: Bool = false

    init(label: LocalizedStringKey? = nil,
         placeholder: LocalizedStringKey,
         text: Binding<String>,
         isSecure: Bool = false,
         keyboardType: UIKeyboardType = .default,
         contentType: UITextContentType? = nil,
         submitLabel: SubmitLabel = .done,
         size: Size = .medium,
         leadingSystemImage: String? = nil,
         trailingSystemImage: String? = nil,
         error: LocalizedStringKey? = nil,
         onSubmit: @escaping () -> Void = {},
         preventAutoLinkStyling: Bool = false,
         placeholderKeyForMask: String? = nil) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.contentType = contentType
        self.submitLabel = submitLabel
        self.size = size
        self.leadingSystemImage = leadingSystemImage
        self.trailingSystemImage = trailingSystemImage
        self.error = error
        self.onSubmit = onSubmit
        self.preventAutoLinkStyling = preventAutoLinkStyling
        self.placeholderKeyForMask = placeholderKeyForMask
    }

    // Backward-compatible initializer (no placeholderKeyForMask) to satisfy callers compiled
    // against the older signature mentioned in the undefined symbol error.
    init(label: LocalizedStringKey? = nil,
         placeholder: LocalizedStringKey,
         text: Binding<String>,
         isSecure: Bool = false,
         keyboardType: UIKeyboardType = .default,
         contentType: UITextContentType? = nil,
         submitLabel: SubmitLabel = .done,
         size: Size = .medium,
         leadingSystemImage: String? = nil,
         trailingSystemImage: String? = nil,
         error: LocalizedStringKey? = nil,
         onSubmit: @escaping () -> Void = {},
         preventAutoLinkStyling: Bool = false) {
        self.init(
            label: label,
            placeholder: placeholder,
            text: text,
            isSecure: isSecure,
            keyboardType: keyboardType,
            contentType: contentType,
            submitLabel: submitLabel,
            size: size,
            leadingSystemImage: leadingSystemImage,
            trailingSystemImage: trailingSystemImage,
            error: error,
            onSubmit: onSubmit,
            preventAutoLinkStyling: preventAutoLinkStyling,
            placeholderKeyForMask: nil
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let label {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(.secondaryLabel))
            }
            HStack(spacing: 8) {
                if let leadingSystemImage {
                    Image(systemName: leadingSystemImage)
                        .foregroundStyle(.secondary)
                }
                ZStack(alignment: .leading) {
                    if isSecure && !isPasswordVisible {
                        SecureField("", text: $text)
                            .textContentType(contentType)
                    } else {
                        TextField("", text: $text)
                            .textContentType(contentType)
                    }
                    if text.isEmpty {
                        if preventAutoLinkStyling {
                            Text(verbatim: maskedPlaceholder)
                                .foregroundColor(Color(.secondaryLabel))
                                .allowsHitTesting(false)
                        } else {
                            Text(placeholder)
                                .foregroundColor(Color(.secondaryLabel))
                                .allowsHitTesting(false)
                        }
                    }
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(keyboardType)
                .submitLabel(submitLabel)
                .onSubmit { onSubmit() }
                if isSecure {
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                } else if let trailingSystemImage {
                    Image(systemName: trailingSystemImage)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(borderColor, lineWidth: 0.5)
                    )
            )
            if let error {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        }
    }

    private var borderColor: Color {
        if error != nil {
            return Color.red.opacity(0.6)
        }
        return Color(.separator)
    }

    private var maskedPlaceholder: String {
        let key = placeholderKeyForMask ?? ""
        let localized = NSLocalizedString(key, comment: "AppTextField placeholder")
        if let at = localized.firstIndex(of: "@") {
            var s = localized
            s.insert("\u{200B}", at: at)
            return s
        }
        return localized
    }
}
