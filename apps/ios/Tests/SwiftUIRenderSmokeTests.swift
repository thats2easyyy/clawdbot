import Network
import OpenClawKit
import SwiftUI
import Testing
import UIKit
@testable import OpenClaw

struct SwiftUIRenderSmokeTests {
    @MainActor private static func host(_ view: some View, size: CGSize? = nil) -> UIWindow {
        let frame = CGRect(origin: .zero, size: size ?? UIScreen.main.bounds.size)
        let window = UIWindow(frame: frame)
        window.rootViewController = UIHostingController(rootView: view)
        window.makeKeyAndVisible()
        window.rootViewController?.view.setNeedsLayout()
        window.rootViewController?.view.layoutIfNeeded()
        return window
    }

    @Test @MainActor func `settings pro tab builds A view hierarchy`() {
        let appModel = NodeAppModel()
        let gatewayController = GatewayConnectionController(appModel: appModel, startDiscovery: false)

        let root = SettingsProTab()
            .environment(appModel)
            .environment(appModel.voiceWake)
            .environment(gatewayController)

        _ = Self.host(root)
    }

    @Test @MainActor func `settings pro tab builds in light and dark mode`() {
        for scheme in [ColorScheme.light, ColorScheme.dark] {
            let appModel = NodeAppModel()
            let gatewayController = GatewayConnectionController(appModel: appModel, startDiscovery: false)

            let root = SettingsProTab()
                .environment(appModel)
                .environment(appModel.voiceWake)
                .environment(gatewayController)
                .preferredColorScheme(scheme)

            _ = Self.host(root)
        }
    }

    @Test @MainActor func `gateway quick setup builds candidate and empty states`() {
        let gateways: [GatewayDiscoveryModel.DiscoveredGateway?] = [
            .previewGateway,
            nil,
        ]

        for gateway in gateways {
            let appModel = NodeAppModel()
            let gatewayController = GatewayConnectionController(appModel: appModel, startDiscovery: false)
            if let gateway {
                gatewayController._test_setGateways([gateway])
                appModel.gatewayStatusText = "Ready to pair"
            }

            let root = GatewayQuickSetupSheet()
                .environment(appModel)
                .environment(gatewayController)
                .openClawSheetChrome()

            _ = Self.host(root, size: CGSize(width: 393, height: 520))
        }
    }

    @Test @MainActor func `onboarding activation screens build across appearance and type size`() {
        let screens: [AnyView] = [
            AnyView(OnboardingIntroStep(onContinue: {})),
            AnyView(OnboardingWelcomeStep(
                statusLine: "",
                isConnecting: false,
                onScanQRCode: {},
                onManualSetup: {})),
            AnyView(OnboardingSuccessStep(
                gatewayName: "OpenClaw Gateway",
                gatewayAddress: "openclaw.local",
                onGetStarted: {})),
            AnyView(NavigationStack {
                Form {
                    Section("Connection Mode") {
                        OnboardingModeRow(
                            title: "Home Network",
                            subtitle: "LAN or Tailscale host",
                            symbol: "house.and.flag",
                            selected: true,
                            action: {})
                        OnboardingModeRow(
                            title: "Remote Domain",
                            subtitle: "VPS with domain",
                            symbol: "globe",
                            selected: false,
                            action: {})
                    }
                }
                .scrollContentBackground(.hidden)
                .background(OpenClawBrand.activationCanvas)
            }),
        ]

        for scheme in [ColorScheme.light, ColorScheme.dark] {
            for screen in screens {
                let root = screen
                    .preferredColorScheme(scheme)
                    .environment(\.dynamicTypeSize, .accessibility2)
                _ = Self.host(root, size: CGSize(width: 393, height: 852))
            }
        }
    }

    @Test @MainActor func `root tabs builds device orientation shell matrix`() {
        for scenario in Self.rootTabsShellScenarios() {
            let appModel = NodeAppModel()
            let gatewayController = GatewayConnectionController(appModel: appModel, startDiscovery: false)

            let root = RootTabs()
                .environment(appModel)
                .environment(appModel.voiceWake)
                .environment(gatewayController)
                .environment(\.rootTabsUserInterfaceIdiomOverride, scenario.idiom)
                .environment(\.horizontalSizeClass, scenario.horizontalSizeClass)
                .environment(\.verticalSizeClass, scenario.verticalSizeClass)

            _ = Self.host(root, size: scenario.size)
        }
    }

    @Test @MainActor func `root tabs build gateway state view hierarchies`() {
        for appModel in Self.rootTabsGatewayStateModels() {
            let gatewayController = GatewayConnectionController(appModel: appModel, startDiscovery: false)

            let root = RootTabs()
                .environment(appModel)
                .environment(appModel.voiceWake)
                .environment(gatewayController)

            _ = Self.host(root)
        }
    }

    @Test @MainActor func `phone control hub builds gateway state view hierarchies`() {
        for appModel in Self.rootTabsGatewayStateModels() {
            let root = RootTabsPhoneControlHub(
                groups: RootTabs.phoneControlGroups,
                initialDestination: nil,
                openRootDestination: { _ in })
                .environment(appModel)

            _ = Self.host(root)
        }
    }

    @Test @MainActor func `phone control hub builds landscape compact state`() {
        let appModel = NodeAppModel()
        let root = RootTabsPhoneControlHub(
            groups: RootTabs.phoneControlGroups,
            initialDestination: nil,
            openRootDestination: { _ in })
            .environment(appModel)
            .environment(\.horizontalSizeClass, .regular)
            .environment(\.verticalSizeClass, .compact)

        _ = Self.host(root)
    }

    @Test @MainActor func `routed sidebar screens build offline states`() {
        let appModel = NodeAppModel()
        let screens: [AnyView] = [
            AnyView(CommandCenterTab(openChat: {}, openSettings: {})),
            AnyView(IPadActivityScreen(openChat: {}, openSettings: {})),
            AnyView(OpenClawDocsScreen()),
            AnyView(IPadWorkboardScreen(openChat: {}, openSettings: {})),
            AnyView(IPadSkillWorkshopScreen(openSettings: {})),
            AnyView(AgentProTab(directRoute: .agents)),
            AnyView(AgentProTab(directRoute: .instances)),
            AnyView(CommandSessionsScreen(openChat: {})),
            AnyView(AgentProTab(directRoute: .dreaming)),
            AnyView(AgentProTab(directRoute: .usage)),
            AnyView(AgentProTab(directRoute: .cron)),
        ]

        for screen in screens {
            let root = NavigationStack { screen }
                .environment(appModel)
            _ = Self.host(root)
        }
    }

    @Test @MainActor func `task screens build phone landscape compact states`() {
        let appModel = NodeAppModel()
        let screens: [AnyView] = [
            AnyView(IPadWorkboardScreen(openChat: {}, openSettings: {})),
            AnyView(IPadSkillWorkshopScreen(openSettings: {})),
        ]

        for screen in screens {
            let root = NavigationStack { screen }
                .environment(appModel)
                .environment(\.horizontalSizeClass, .regular)
                .environment(\.verticalSizeClass, .compact)

            _ = Self.host(root)
        }
    }

    @Test @MainActor func `voice wake words view builds A view hierarchy`() {
        let appModel = NodeAppModel()
        let root = NavigationStack { VoiceWakeWordsSettingsView() }
            .environment(appModel)
        _ = Self.host(root)
    }

    @Test @MainActor func `voice wake toast builds A view hierarchy`() {
        let root = VoiceWakeToast(command: "openclaw: do something")
        _ = Self.host(root)
    }

    @MainActor private static func rootTabsGatewayStateModels() -> [NodeAppModel] {
        let offlineModel = NodeAppModel()

        let connectingModel = NodeAppModel()
        connectingModel.gatewayStatusText = "Connecting…"

        let connectedModel = NodeAppModel()
        connectedModel.enterAppleReviewDemoMode()

        let errorModel = NodeAppModel()
        errorModel.gatewayStatusText = "Gateway error: connection refused"

        return [offlineModel, connectingModel, connectedModel, errorModel]
    }

    private static func rootTabsShellScenarios() -> [RootTabsShellScenario] {
        [
            RootTabsShellScenario(
                idiom: .phone,
                size: CGSize(width: 393, height: 852),
                horizontalSizeClass: .compact,
                verticalSizeClass: .regular),
            RootTabsShellScenario(
                idiom: .phone,
                size: CGSize(width: 852, height: 393),
                horizontalSizeClass: .regular,
                verticalSizeClass: .compact),
            RootTabsShellScenario(
                idiom: .pad,
                size: CGSize(width: 1024, height: 1366),
                horizontalSizeClass: .regular,
                verticalSizeClass: .regular),
            RootTabsShellScenario(
                idiom: .pad,
                size: CGSize(width: 1366, height: 1024),
                horizontalSizeClass: .regular,
                verticalSizeClass: .regular),
        ]
    }

    private struct RootTabsShellScenario {
        let idiom: UIUserInterfaceIdiom
        let size: CGSize
        let horizontalSizeClass: UserInterfaceSizeClass
        let verticalSizeClass: UserInterfaceSizeClass
    }
}

extension GatewayDiscoveryModel.DiscoveredGateway {
    fileprivate static let previewGateway = GatewayDiscoveryModel.DiscoveredGateway(
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
