import SwiftUI

enum AppAppearancePreference: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    static let storageKey = "appearance.preference"

    static var launchArgumentPreference: AppAppearancePreference? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flagIndex = arguments.firstIndex(of: "--openclaw-appearance") else {
            return nil
        }
        let valueIndex = arguments.index(after: flagIndex)
        guard arguments.indices.contains(valueIndex) else { return nil }
        return AppAppearancePreference(rawValue: arguments[valueIndex].lowercased())
    }

    var id: String {
        self.rawValue
    }

    var label: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light: .light
        case .dark: .dark
        }
    }
}

enum OpenClawBrand {
    static let uiAccent = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 198 / 255.0, green: 62 / 255.0, blue: 56 / 255.0, alpha: 1)
            : UIColor(red: 183 / 255.0, green: 56 / 255.0, blue: 51 / 255.0, alpha: 1)
    }

    static let accent = Color(uiColor: Self.uiAccent)
    static let accentHot = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 232 / 255.0, green: 92 / 255.0, blue: 86 / 255.0, alpha: 1)
            : UIColor(red: 204 / 255.0, green: 75 / 255.0, blue: 69 / 255.0, alpha: 1)
    })
    static let danger = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 252 / 255.0, green: 165 / 255.0, blue: 165 / 255.0, alpha: 1)
            : UIColor(red: 185 / 255.0, green: 28 / 255.0, blue: 28 / 255.0, alpha: 1)
    })
    static let ok = Color(red: 34 / 255.0, green: 197 / 255.0, blue: 94 / 255.0)
    static let warn = Color(red: 245 / 255.0, green: 158 / 255.0, blue: 11 / 255.0)
    static let info = Color(red: 0 / 255.0, green: 122 / 255.0, blue: 255 / 255.0)
    static let activationCanvas = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 18 / 255.0, green: 14 / 255.0, blue: 15 / 255.0, alpha: 1)
            : UIColor.white
    })
    static let activationSurface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 33 / 255.0, green: 29 / 255.0, blue: 30 / 255.0, alpha: 1)
            : UIColor(red: 255 / 255.0, green: 253 / 255.0, blue: 252 / 255.0, alpha: 1)
    })
    static let activationInsetSurface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 44 / 255.0, green: 37 / 255.0, blue: 38 / 255.0, alpha: 1)
            : UIColor(red: 246 / 255.0, green: 241 / 255.0, blue: 238 / 255.0, alpha: 1)
    })
    static let activationNeutralSurface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 34 / 255.0, green: 34 / 255.0, blue: 37 / 255.0, alpha: 1)
            : UIColor(red: 242 / 255.0, green: 242 / 255.0, blue: 247 / 255.0, alpha: 1)
    })
    static let activationNeutralInsetSurface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 42 / 255.0, green: 42 / 255.0, blue: 45 / 255.0, alpha: 1)
            : UIColor(red: 247 / 255.0, green: 247 / 255.0, blue: 249 / 255.0, alpha: 1)
    })
    static let activationNeutralStroke = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.10)
            : UIColor.black.withAlphaComponent(0.07)
    })
    static let activationNeutralDivider = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.09)
            : UIColor.black.withAlphaComponent(0.08)
    })
    static let activationPrimaryAction = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 238 / 255.0, green: 82 / 255.0, blue: 76 / 255.0, alpha: 1)
            : UIColor(red: 209 / 255.0, green: 54 / 255.0, blue: 51 / 255.0, alpha: 1)
    })
    static let activationPrimaryActionText = Color.white
    static let activationHairline = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 255 / 255.0, green: 210 / 255.0, blue: 205 / 255.0, alpha: 0.13)
            : UIColor(red: 136 / 255.0, green: 44 / 255.0, blue: 40 / 255.0, alpha: 0.13)
    })
    static let activationGlow = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 255 / 255.0, green: 111 / 255.0, blue: 96 / 255.0, alpha: 1)
            : UIColor(red: 228 / 255.0, green: 78 / 255.0, blue: 67 / 255.0, alpha: 1)
    })
    static let graphite = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 20 / 255.0, green: 22 / 255.0, blue: 24 / 255.0, alpha: 1)
            : UIColor(red: 246 / 255.0, green: 247 / 255.0, blue: 249 / 255.0, alpha: 1)
    })
    static let graphiteElevated = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 34 / 255.0, green: 36 / 255.0, blue: 39 / 255.0, alpha: 1)
            : UIColor.white
    })

    static var sheetBackground: LinearGradient {
        LinearGradient(
            colors: [
                graphite,
                graphiteElevated.opacity(0.96),
                Color(uiColor: .systemBackground),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    }

    static var activationCanvasGradient: LinearGradient {
        LinearGradient(
            colors: [
                activationCanvas,
                activationCanvas,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    }

    static var activationSurfaceGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.16),
                activationSurface,
                activationSurface,
                activationGlow.opacity(0.06),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    }

    static var activationInsetGradient: LinearGradient {
        LinearGradient(
            colors: [
                activationInsetSurface.opacity(0.94),
                activationInsetSurface,
                activationSurface.opacity(0.36),
            ],
            startPoint: .top,
            endPoint: .bottom)
    }

    static var activationNeutralGradient: LinearGradient {
        LinearGradient(
            colors: [
                activationNeutralInsetSurface,
                activationNeutralSurface,
            ],
            startPoint: .top,
            endPoint: .bottom)
    }

    static var activationPrimaryGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.42, blue: 0.34),
                activationGlow,
                activationPrimaryAction,
                Color(red: 0.66, green: 0.12, blue: 0.12),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    }

    static var activationDisabledGradient: LinearGradient {
        LinearGradient(
            colors: [
                activationNeutralInsetSurface,
                activationNeutralSurface.opacity(0.92),
            ],
            startPoint: .top,
            endPoint: .bottom)
    }

    static var activationPrimaryStroke: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.36),
                activationGlow.opacity(0.58),
                Color.black.opacity(0.18),
            ],
            startPoint: .top,
            endPoint: .bottom)
    }

    static var activationSurfaceStroke: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.72),
                activationHairline,
                Color.black.opacity(0.08),
            ],
            startPoint: .top,
            endPoint: .bottom)
    }
}

extension View {
    func openClawSheetChrome() -> some View {
        self
            .tint(OpenClawBrand.accent)
            .background {
                OpenClawBrand.sheetBackground
                    .ignoresSafeArea()
            }
    }

    func openClawCraftSurface(cornerRadius: CGFloat = 24, shadow: Bool = true) -> some View {
        self.modifier(OpenClawCraftSurfaceModifier(cornerRadius: cornerRadius, shadow: shadow))
    }
}

private struct OpenClawCraftSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    let shadow: Bool

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
                    .fill(OpenClawBrand.activationSurface)
                    .shadow(
                        color: self.shadow ? Color.black.opacity(0.07) : .clear,
                        radius: 16,
                        x: 0,
                        y: 8)
            }
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.36), lineWidth: 0.5)
                    .blendMode(.plusLighter)
            }
            .overlay {
                RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
                    .stroke(OpenClawBrand.activationHairline, lineWidth: 0.5)
            }
    }
}

struct OpenClawPrimaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var height: CGFloat = 54
    var cornerRadius: CGFloat = 18

    private var resolvedCornerRadius: CGFloat {
        self.height / 2
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(self.isEnabled ? OpenClawBrand.activationPrimaryActionText : Color.secondary)
            .tint(self.isEnabled ? OpenClawBrand.activationPrimaryActionText : Color.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: self.height)
            .background {
                RoundedRectangle(cornerRadius: self.resolvedCornerRadius, style: .continuous)
                    .fill(self.isEnabled ? Self.primaryFill : OpenClawBrand.activationDisabledGradient)
                    .shadow(
                        color: self.isEnabled ? OpenClawBrand.activationPrimaryAction.opacity(0.08) : .clear,
                        radius: 1,
                        x: 0,
                        y: 1)
                    .shadow(
                        color: self.isEnabled ? OpenClawBrand.activationPrimaryAction.opacity(0.08) : .clear,
                        radius: 2,
                        x: 0,
                        y: 2)
            }
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: self.resolvedCornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(self.isEnabled ? 0.14 : 0.06),
                                Color.white.opacity(0),
                            ],
                            startPoint: .top,
                            endPoint: .center))
                    .frame(height: self.height * 0.48)
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .bottom) {
                RoundedRectangle(cornerRadius: self.resolvedCornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(self.isEnabled ? 0.08 : 0.03),
                            ],
                            startPoint: .top,
                            endPoint: .bottom))
                    .frame(height: self.height * 0.34)
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: self.resolvedCornerRadius, style: .continuous)
                    .stroke(
                        self.isEnabled
                            ? OpenClawBrand.activationPrimaryAction.opacity(0.72)
                            : OpenClawBrand.activationNeutralStroke,
                        lineWidth: 0.75)
            }
            .scaleEffect(configuration.isPressed && self.isEnabled ? 0.98 : 1)
            .animation(.smooth(duration: 0.14), value: configuration.isPressed)
    }

    private static var primaryFill: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.93, green: 0.27, blue: 0.25),
                Color(red: 0.91, green: 0.25, blue: 0.24),
            ],
            startPoint: .top,
            endPoint: .bottom)
    }
}

struct OpenClawSecondaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var height: CGFloat = 50
    var cornerRadius: CGFloat = 18

    private var resolvedCornerRadius: CGFloat {
        self.height / 2
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(self.isEnabled ? OpenClawBrand.activationPrimaryAction : .secondary)
            .frame(maxWidth: .infinity)
            .frame(height: self.height)
            .background {
                RoundedRectangle(cornerRadius: self.resolvedCornerRadius, style: .continuous)
                    .fill(Self.secondaryFill)
                    .shadow(
                        color: self.isEnabled ? Color.black.opacity(0.035) : .clear,
                        radius: 1,
                        x: 0,
                        y: 1)
                    .shadow(
                        color: self.isEnabled ? Color.black.opacity(0.035) : .clear,
                        radius: 2,
                        x: 0,
                        y: 2)
            }
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: self.resolvedCornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.42),
                                Color.white.opacity(0),
                            ],
                            startPoint: .top,
                            endPoint: .center))
                    .frame(height: self.height * 0.48)
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: self.resolvedCornerRadius, style: .continuous)
                    .stroke(OpenClawBrand.activationHairline, lineWidth: 0.75)
            }
            .scaleEffect(configuration.isPressed && self.isEnabled ? 0.98 : 1)
            .animation(.smooth(duration: 0.14), value: configuration.isPressed)
    }

    private static var secondaryFill: LinearGradient {
        LinearGradient(
            colors: [
                OpenClawBrand.activationSurface,
                OpenClawBrand.activationSurface.opacity(0.96),
            ],
            startPoint: .top,
            endPoint: .bottom)
    }
}

struct OpenClawTertiaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var height: CGFloat = 44

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.semibold))
            .foregroundStyle(
                self.isEnabled
                    ? OpenClawBrand.activationPrimaryAction.opacity(0.78)
                    : Color.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: self.height)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed && self.isEnabled ? 0.66 : 1)
            .scaleEffect(configuration.isPressed && self.isEnabled ? 0.985 : 1)
            .animation(.smooth(duration: 0.14), value: configuration.isPressed)
    }
}

struct OpenClawCloseButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(
                self.isEnabled
                    ? OpenClawBrand.activationPrimaryAction
                    : Color.secondary)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.vertical, 7)
            .padding(.horizontal, 11)
            .background {
                Capsule(style: .continuous)
                    .fill(OpenClawBrand.activationNeutralSurface.opacity(0.92))
                    .shadow(
                        color: self.isEnabled ? Color.black.opacity(0.035) : .clear,
                        radius: 1,
                        x: 0,
                        y: 1)
                    .shadow(
                        color: self.isEnabled ? Color.black.opacity(0.025) : .clear,
                        radius: 3,
                        x: 0,
                        y: 2)
            }
            .overlay {
                Capsule(style: .continuous)
                    .stroke(OpenClawBrand.activationNeutralStroke, lineWidth: 0.5)
            }
            .contentShape(Capsule(style: .continuous))
            .opacity(configuration.isPressed && self.isEnabled ? 0.66 : 1)
            .scaleEffect(configuration.isPressed && self.isEnabled ? 0.98 : 1)
            .animation(.smooth(duration: 0.14), value: configuration.isPressed)
    }
}
