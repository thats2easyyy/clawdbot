import OpenClawKit
import SwiftUI

#if DEBUG
import Network
#endif

struct GatewayQuickSetupSheet: View {
    @Environment(NodeAppModel.self) private var appModel
    @Environment(GatewayConnectionController.self) private var gatewayController
    @Environment(\.dismiss) private var dismiss

    @AppStorage("onboarding.quickSetupDismissed") private var quickSetupDismissed: Bool = false
    @State private var connecting: Bool = false
    @State private var connectError: String?
    @State private var showGatewayProblemDetails: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    GatewayQuickSetupHeader(hasCandidate: self.bestCandidate != nil)

                    if let gatewayProblem = self.appModel.lastGatewayProblem {
                        GatewayProblemBanner(
                            problem: gatewayProblem,
                            primaryActionTitle: self.gatewayProblemPrimaryActionTitle(gatewayProblem),
                            onPrimaryAction: {
                                Task { await self.handleGatewayProblemPrimaryAction(gatewayProblem) }
                            },
                            onShowDetails: {
                                self.showGatewayProblemDetails = true
                            })
                    }

                    if let candidate = self.bestCandidate {
                        GatewayQuickSetupCandidatePanel(
                            name: candidate.name,
                            debugID: candidate.debugID,
                            host: candidate.lanHost ?? candidate.tailnetDns,
                            tlsEnabled: candidate.tlsEnabled,
                            gatewayPort: candidate.gatewayPort,
                            discoveryStatusText: self.gatewayController.discoveryStatusText,
                            gatewayDisplayStatusText: self.appModel.gatewayDisplayStatusText,
                            nodeStatusText: self.appModel.nodeStatusText,
                            operatorStatusText: self.appModel.operatorStatusText)

                        Button {
                            self.connectError = nil
                            self.connecting = true
                            Task {
                                let err = await self.gatewayController.connectWithDiagnostics(candidate)
                                await MainActor.run {
                                    self.connecting = false
                                    self.connectError = err
                                    // If we kicked off a connect, leave the sheet up so the user can see status evolve.
                                }
                            }
                        } label: {
                            Group {
                                if self.connecting {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .tint(.white)
                                        Text("Connecting…")
                                    }
                                } else {
                                    Text("Connect")
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .openClawGlassButton(prominent: true)
                        .controlSize(.large)
                        .disabled(self.connecting)

                        if let connectError {
                            GatewayQuickSetupErrorView(message: connectError)
                        }

                        Button {
                            self.dismiss()
                        } label: {
                            Text("Not now")
                                .frame(maxWidth: .infinity)
                        }
                        .openClawGlassButton()
                        .controlSize(.large)
                        .disabled(self.connecting)

                        self.fullRowToggle("Don’t show this again", isOn: self.$quickSetupDismissed)
                            .padding(.top, 2)
                    } else {
                        GatewayQuickSetupEmptyState(
                            discoveryStatusText: self.gatewayController.discoveryStatusText)
                    }
                }
                .padding(20)
            }
            .background(OpenClawBrand.activationCanvas)
            .navigationTitle("Quick Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.quickSetupDismissed = true
                        self.dismiss()
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
        .sheet(isPresented: self.$showGatewayProblemDetails) {
            if let gatewayProblem = self.appModel.lastGatewayProblem {
                GatewayProblemDetailsSheet(
                    problem: gatewayProblem,
                    primaryActionTitle: self.gatewayProblemPrimaryActionTitle(gatewayProblem),
                    onPrimaryAction: {
                        Task { await self.handleGatewayProblemPrimaryAction(gatewayProblem) }
                    })
            }
        }
    }

    private var bestCandidate: GatewayDiscoveryModel.DiscoveredGateway? {
        // Prefer whatever discovery says is first; the list is already name-sorted.
        self.gatewayController.gateways.first
    }

    private func fullRowToggle(_ title: LocalizedStringKey, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .contentShape(Rectangle())
            .overlay {
                // Keep Toggle semantics for accessibility while making the full visual row tappable.
                Button {
                    isOn.wrappedValue.toggle()
                } label: {
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityHidden(true)
            }
    }

    private func gatewayProblemPrimaryActionTitle(_ problem: GatewayConnectionProblem) -> String? {
        GatewayProblemPrimaryAction.title(for: problem, retryTitle: "Connect")
    }

    private func handleGatewayProblemPrimaryAction(_ problem: GatewayConnectionProblem) async {
        if problem.canTrustRotatedCertificate {
            _ = await self.gatewayController.trustRotatedGatewayCertificate(from: problem)
            return
        }
        if GatewayProblemPrimaryAction.openProtocolMismatchHelpIfNeeded(problem) {
            return
        }
        guard problem.retryable else { return }
        guard let candidate = self.bestCandidate else { return }
        self.connectError = nil
        self.connecting = true
        let err = await self.gatewayController.connectWithDiagnostics(candidate)
        self.connecting = false
        self.connectError = err
    }
}

private struct GatewayQuickSetupHeader: View {
    // Scale badge containers with type so glyphs never overflow their fills.
    @ScaledMetric(relativeTo: .caption) private var badgeSize: CGFloat = 28
    let hasCandidate: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Image(decorative: "OpenClawIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 54)
                    .padding(8)
                    .openClawActivationSurface()

                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: self.badgeSize, height: self.badgeSize)
                    .background {
                        Circle()
                            .fill(OpenClawBrand.accent)
                    }
                    .overlay {
                        Circle()
                            .stroke(OpenClawBrand.activationCanvas, lineWidth: 3)
                    }
                    .offset(x: 4, y: 4)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text("Connect to a Gateway?")
                    .font(.title2.weight(.semibold))
                Text(self.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var subtitle: LocalizedStringKey {
        if self.hasCandidate {
            return "OpenClaw found a gateway on this network. Review it, then pair this iPhone as a secure node."
        }
        return "OpenClaw is searching the local network and tailnet for a Gateway you can trust."
    }
}

private struct GatewayQuickSetupCandidatePanel: View {
    @ScaledMetric(relativeTo: .headline) private var badgeSize: CGFloat = 36
    let name: String
    let debugID: String
    let host: String?
    let tlsEnabled: Bool
    let gatewayPort: Int?
    let discoveryStatusText: String
    let gatewayDisplayStatusText: String
    let nodeStatusText: String
    let operatorStatusText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "network")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: self.badgeSize, height: self.badgeSize)
                    .background {
                        RoundedRectangle(cornerRadius: OpenClawProMetric.controlRadius, style: .continuous)
                            .fill(OpenClawBrand.accent)
                    }
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(verbatim: self.name)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .truncationMode(.middle)

                        if self.tlsEnabled {
                            GatewayQuickSetupChip(text: "TLS")
                        }
                    }

                    Text(verbatim: self.endpointSummary)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .accessibilityElement(children: .combine)
            }

            Divider()

            VStack(spacing: 8) {
                GatewayQuickSetupStatusRow(title: "Discovery", value: self.discoveryStatusText)
                GatewayQuickSetupStatusRow(title: "Gateway", value: self.gatewayDisplayStatusText)
                GatewayQuickSetupStatusRow(title: "Node", value: self.nodeStatusText)
                GatewayQuickSetupStatusRow(title: "Operator", value: self.operatorStatusText)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .textSelection(.enabled)
        .openClawActivationSurface()
    }

    private var endpointSummary: String {
        // debugID is the Bonjour service description, not a connectable address;
        // only a real host earns the :port suffix.
        guard let host, !host.isEmpty else { return self.debugID }
        let port = self.gatewayPort.map { ":\($0)" } ?? ""
        return "\(host)\(port)"
    }
}

private struct GatewayQuickSetupChip: View {
    let text: String

    var body: some View {
        Text(verbatim: self.text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background {
                Capsule(style: .continuous)
                    .fill(OpenClawBrand.activationInsetSurface)
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(OpenClawBrand.activationHairline, lineWidth: 0.75)
            }
    }
}

private struct GatewayQuickSetupStatusRow: View {
    // Scale the label column with type so titles never truncate at accessibility sizes.
    @ScaledMetric(relativeTo: .caption) private var titleWidth: CGFloat = 70
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(self.title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(minWidth: self.titleWidth, alignment: .leading)
            // Bonjour-provided values must stay Text(verbatim:) so they can't be
            // interpreted as localized format strings (Objective-C exception crash).
            Text(verbatim: self.value)
                .font(.footnote)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct GatewayQuickSetupErrorView: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(OpenClawBrand.warn)
                .padding(.top, 1)
            Text(self.message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: OpenClawProMetric.controlRadius, style: .continuous)
                .fill(OpenClawBrand.activationInsetSurface)
        }
        .overlay {
            RoundedRectangle(cornerRadius: OpenClawProMetric.controlRadius, style: .continuous)
                .strokeBorder(OpenClawBrand.activationHairline, lineWidth: 0.75)
        }
    }
}

private struct GatewayQuickSetupEmptyState: View {
    @ScaledMetric(relativeTo: .title3) private var badgeSize: CGFloat = 42
    let discoveryStatusText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.title3.weight(.semibold))
                .foregroundStyle(OpenClawBrand.accent)
                .frame(width: self.badgeSize, height: self.badgeSize)
                .background {
                    RoundedRectangle(cornerRadius: OpenClawProMetric.controlRadius, style: .continuous)
                        .fill(OpenClawBrand.activationInsetSurface)
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text("Looking for a Gateway")
                    .font(.headline)
                Text("No gateways found yet. Make sure your gateway is running and Bonjour discovery is enabled.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(verbatim: "openclaw gateway")
                .font(.system(.footnote, design: .monospaced).weight(.semibold))
                .foregroundStyle(.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background {
                    RoundedRectangle(cornerRadius: OpenClawProMetric.controlRadius, style: .continuous)
                        .fill(OpenClawBrand.activationInsetSurface)
                }
                .textSelection(.enabled)

            Text(verbatim: "Discovery: \(self.discoveryStatusText)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .openClawActivationSurface()
    }
}

#if DEBUG
#Preview("Quick setup gateway", traits: .fixedLayout(width: 393, height: 520)) {
    GatewayQuickSetupPreviewHost(hasGateway: true)
}

#Preview("Quick setup searching", traits: .fixedLayout(width: 393, height: 520)) {
    GatewayQuickSetupPreviewHost(hasGateway: false)
}

private struct GatewayQuickSetupPreviewHost: View {
    @State private var appModel: NodeAppModel
    @State private var gatewayController: GatewayConnectionController

    init(hasGateway: Bool) {
        let appModel = NodeAppModel()
        let controller = GatewayConnectionController(appModel: appModel, startDiscovery: false)
        if hasGateway {
            controller._test_setGateways([.previewGateway])
            appModel.gatewayStatusText = "Ready to pair"
        }
        _appModel = State(initialValue: appModel)
        _gatewayController = State(initialValue: controller)
    }

    var body: some View {
        GatewayQuickSetupSheet()
            .environment(self.appModel)
            .environment(self.gatewayController)
            .openClawSheetChrome()
    }
}

/// Shared with SwiftUIRenderSmokeTests so the fixture exists exactly once.
extension GatewayDiscoveryModel.DiscoveredGateway {
    static let previewGateway = GatewayDiscoveryModel.DiscoveredGateway(
        name: "Studio Gateway",
        endpoint: .hostPort(
            host: .name("openclaw.local", nil),
            port: 18789),
        stableID: "preview-gateway",
        debugID: "openclaw.local",
        lanHost: "openclaw.local",
        tailnetDns: nil,
        gatewayPort: 18789,
        canvasPort: 18789,
        tlsEnabled: true,
        tlsFingerprintSha256: "preview",
        cliPath: "/opt/homebrew/bin/openclaw")
}
#endif
