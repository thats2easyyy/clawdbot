import SwiftUI
import UIKit

/// Layout for the full-screen activation steps (intro / welcome / success).
private enum OnboardingLayout {
    /// Cap content width so landscape phones and iPads keep a readable column.
    static let maxContentWidth: CGFloat = 430
    static let horizontalPadding: CGFloat = 20
    static let topPadding: CGFloat = 56
    static let bottomPadding: CGFloat = 40
    static let sectionGap: CGFloat = 40
    static let panelGap: CGFloat = 16
    static let rowSpacing: CGFloat = 12
}

private struct OnboardingActivationCanvas<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                self.content
                    .frame(maxWidth: OnboardingLayout.maxContentWidth)
                    .frame(maxWidth: .infinity)
                    // Fill the viewport minus the vertical paddings applied below so short
                    // content can bottom-anchor its primary action with a Spacer.
                    .frame(
                        minHeight: max(
                            0,
                            proxy.size.height
                                - OnboardingLayout.topPadding
                                - OnboardingLayout.bottomPadding),
                        alignment: .top)
                    .padding(.horizontal, OnboardingLayout.horizontalPadding)
                    .padding(.top, OnboardingLayout.topPadding)
                    .padding(.bottom, OnboardingLayout.bottomPadding)
            }
            .scrollIndicators(.hidden)
            .background(OpenClawBrand.activationCanvas.ignoresSafeArea())
        }
    }
}

private struct OnboardingHeroGlyph: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        Image(decorative: "OpenClawIcon")
            .resizable()
            .scaledToFit()
            .frame(width: 78, height: 78)
            .opacity(self.appeared ? 1 : 0)
            .scaleEffect(self.reduceMotion ? 1 : (self.appeared ? 1 : 0.96))
            .animation(
                self.reduceMotion ? .easeOut(duration: 0.12) : .smooth(duration: 0.22),
                value: self.appeared)
            .onAppear {
                self.appeared = true
            }
    }
}

private struct OnboardingHeroHeader: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    var body: some View {
        VStack(spacing: 18) {
            OnboardingHeroGlyph()

            VStack(spacing: 8) {
                Text(self.title)
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)

                Text(self.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct OnboardingPanel<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        self.content
            .padding(OnboardingLayout.panelGap)
            .frame(maxWidth: .infinity, alignment: .leading)
            .openClawActivationSurface()
    }
}

private struct OnboardingIcon: View {
    // Scale the icon container with type size so glyphs never overflow the circle.
    @ScaledMetric(relativeTo: .subheadline) private var iconSize: CGFloat = 34
    let symbol: String
    let tint: Color

    var body: some View {
        Image(systemName: self.symbol)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(self.tint)
            .frame(width: self.iconSize, height: self.iconSize)
            .background {
                Circle()
                    .fill(OpenClawBrand.activationInsetSurface)
            }
            .accessibilityHidden(true)
    }
}

private struct OnboardingSafetyRow: View {
    let symbol: String
    let title: LocalizedStringKey

    var body: some View {
        HStack(spacing: OnboardingLayout.rowSpacing) {
            OnboardingIcon(symbol: self.symbol, tint: OpenClawBrand.accent)

            Text(self.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct OnboardingSecurityNotice: View {
    var body: some View {
        OnboardingPanel {
            HStack(alignment: .top, spacing: OnboardingLayout.rowSpacing) {
                OnboardingIcon(symbol: "exclamationmark.triangle.fill", tint: OpenClawBrand.warn)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Security notice")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(
                        "The connected OpenClaw agent can use device capabilities you enable, "
                            + "such as camera, microphone, photos, contacts, calendar, and location. "
                            + "Continue only if you trust the gateway and agent you connect to.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct OnboardingStepLabel: View {
    let number: Int
    let title: LocalizedStringKey

    var body: some View {
        HStack(spacing: 7) {
            Text(verbatim: "\(self.number).")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(OpenClawBrand.activationAccentText)
            Text(self.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct OnboardingCommandChip: View {
    @State private var didCopy = false
    @State private var resetTask: Task<Void, Never>?

    var body: some View {
        HStack(spacing: 8) {
            Text(verbatim: "/pair qr")
                .font(.system(.title3, design: .monospaced).weight(.semibold))
                .foregroundStyle(.primary)
                .textSelection(.enabled)
            Spacer(minLength: 0)
            Button {
                self.copyCommand()
            } label: {
                Image(systemName: self.didCopy ? "checkmark" : "doc.on.doc")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(self.didCopy ? AnyShapeStyle(OpenClawBrand.accent) : AnyShapeStyle(.secondary))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Copy pair command")
            .accessibilityValue(self.didCopy ? "Copied" : "/pair qr")
        }
        .padding(.vertical, 10)
        .padding(.horizontal, OnboardingLayout.panelGap)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: OpenClawProMetric.controlRadius, style: .continuous)
                .fill(OpenClawBrand.activationInsetSurface)
        }
        .sensoryFeedback(.success, trigger: self.didCopy) { _, copied in copied }
        .onDisappear {
            self.resetTask?.cancel()
        }
    }

    private func copyCommand() {
        UIPasteboard.general.string = "/pair qr"
        // Cancel any pending reset so rapid re-taps keep the checkmark visible.
        self.resetTask?.cancel()
        withAnimation(.smooth(duration: 0.14)) {
            self.didCopy = true
        }
        self.resetTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.smooth(duration: 0.16)) {
                self.didCopy = false
            }
        }
    }
}

struct OnboardingIntroStep: View {
    let onContinue: () -> Void

    var body: some View {
        OnboardingActivationCanvas {
            VStack(alignment: .leading, spacing: 0) {
                OnboardingHeroHeader(
                    title: "OpenClaw",
                    subtitle: "Securely connect this iPhone to your gateway.")
                    .padding(.top, 18)

                OnboardingPanel {
                    VStack(alignment: .leading, spacing: 14) {
                        OnboardingSafetyRow(
                            symbol: "link",
                            title: "Connect to your gateway")
                        OnboardingSafetyRow(
                            symbol: "hand.raised",
                            title: "Choose device permissions")
                        OnboardingSafetyRow(
                            symbol: "message.fill",
                            title: "Use OpenClaw from your phone")
                    }
                }
                .padding(.top, OnboardingLayout.sectionGap)

                OnboardingSecurityNotice()
                    .padding(.top, 18)

                Spacer(minLength: OnboardingLayout.sectionGap)

                Button {
                    self.onContinue()
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .openClawGlassButton(prominent: true)
                .controlSize(.large)
            }
        }
    }
}

struct OnboardingWelcomeStep: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let statusLine: String
    let isConnecting: Bool
    let onScanQRCode: () -> Void
    let onManualSetup: () -> Void

    var body: some View {
        let statusText = self.statusLine.trimmingCharacters(in: .whitespacesAndNewlines)

        OnboardingActivationCanvas {
            VStack(alignment: .leading, spacing: 0) {
                OnboardingHeroHeader(
                    title: "Connect Gateway",
                    subtitle: "Two quick steps to pair this iPhone.")
                    .padding(.top, 18)

                VStack(alignment: .leading, spacing: OnboardingLayout.rowSpacing) {
                    OnboardingStepLabel(number: 1, title: "Run this in OpenClaw")
                    OnboardingCommandChip()
                }
                .padding(.top, OnboardingLayout.sectionGap)

                VStack(alignment: .leading, spacing: OnboardingLayout.rowSpacing) {
                    OnboardingStepLabel(number: 2, title: "Scan the QR code")

                    Button(action: self.onScanQRCode) {
                        Group {
                            if self.isConnecting {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.white)
                                    Text("Connecting…")
                                }
                            } else {
                                Label("Open camera", systemImage: "qrcode.viewfinder")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .openClawGlassButton(prominent: true)
                    .controlSize(.large)
                    .disabled(self.isConnecting)
                }
                .padding(.top, 32)

                if !statusText.isEmpty {
                    Text(statusText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 6)
                        .padding(.top, 14)
                        .transition(.opacity)
                }

                Spacer(minLength: OnboardingLayout.sectionGap)

                Button {
                    self.onManualSetup()
                } label: {
                    Text("Set up manually")
                        .font(.footnote.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .tint(OpenClawBrand.activationAccentText)
                .disabled(self.isConnecting)
            }
            .animation(self.reduceMotion ? nil : .smooth(duration: 0.18), value: statusText)
        }
    }
}

struct OnboardingSuccessStep: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .headline) private var badgeSize: CGFloat = 30
    @State private var revealed = false

    let gatewayName: String
    let gatewayAddress: String?
    let onGetStarted: () -> Void

    var body: some View {
        OnboardingActivationCanvas {
            VStack(spacing: 0) {
                Spacer(minLength: OnboardingLayout.sectionGap)

                ZStack(alignment: .bottomTrailing) {
                    Image(decorative: "OpenClawIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 86, height: 86)
                        .shadow(color: OpenClawBrand.accent.opacity(0.18), radius: 12, x: 0, y: 6)

                    Image(systemName: "checkmark")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Self.checkmarkColor)
                        .frame(width: self.badgeSize, height: self.badgeSize)
                        .background {
                            Circle()
                                .fill(OpenClawBrand.ok)
                        }
                        .overlay {
                            Circle()
                                .stroke(OpenClawBrand.activationCanvas, lineWidth: 3)
                        }
                }
                .accessibilityHidden(true)
                .scaleEffect(self.reduceMotion ? 1 : (self.revealed ? 1 : 0.6))
                .opacity(self.revealed ? 1 : 0)
                .animation(
                    self.reduceMotion ? .easeOut(duration: 0.12) : .spring(duration: 0.4, bounce: 0.25),
                    value: self.revealed)
                .padding(.bottom, 22)

                VStack(spacing: 8) {
                    Text("You’re connected")
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)

                    VStack(spacing: 2) {
                        Text(verbatim: self.gatewayName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        if let gatewayAddress, !gatewayAddress.isEmpty {
                            Text(verbatim: gatewayAddress)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .opacity(self.revealed ? 1 : 0)
                .offset(y: self.reduceMotion || self.revealed ? 0 : 6)
                .animation(
                    self.reduceMotion
                        ? .easeOut(duration: 0.12)
                        : .smooth(duration: 0.3).delay(0.12),
                    value: self.revealed)

                Spacer(minLength: OnboardingLayout.sectionGap)

                Button {
                    self.onGetStarted()
                } label: {
                    Text("Get started")
                        .frame(maxWidth: .infinity)
                }
                .openClawGlassButton(prominent: true)
                .controlSize(.large)
            }
        }
        .onAppear {
            self.revealed = true
        }
        .sensoryFeedback(.success, trigger: self.revealed) { _, revealed in revealed }
    }

    /// White fails contrast on the brighter dark-mode green; flip the mark instead.
    private static let checkmarkColor = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(white: 0.08, alpha: 1) : UIColor.white
    })
}

struct OnboardingModeRow: View {
    @ScaledMetric(relativeTo: .subheadline) private var iconSize: CGFloat = 34
    let title: String
    let subtitle: String
    let symbol: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack(spacing: OnboardingLayout.rowSpacing) {
                Image(systemName: self.symbol)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(self.selected ? Color.white : Color.secondary)
                    .frame(width: self.iconSize, height: self.iconSize)
                    .background {
                        RoundedRectangle(cornerRadius: OpenClawProMetric.controlRadius, style: .continuous)
                            .fill(
                                self.selected
                                    ? AnyShapeStyle(OpenClawBrand.accent)
                                    : AnyShapeStyle(OpenClawBrand.activationInsetSurface))
                    }
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(self.title)
                        .font(.body.weight(.semibold))
                    Text(self.subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: self.selected ? "checkmark.circle.fill" : "circle")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(self.selected ? OpenClawBrand.accent : Color.secondary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(self.selected ? [.isSelected] : [])
    }
}
