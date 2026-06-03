import SwiftUI

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @State private var selectedPhotos: [SelectedPhoto] = []
    @State private var isViewerPresented = false
    @State private var hasCompletedShareSetup: Bool

    private let onboardingTitle = "Set Up Don't Swipe"
    private let onboardingInstructions = [
        "Open Photos",
        "Select Photos",
        "Tap Share",
        "Tap More",
        "Tap Edit",
        "Hit + next to Don't Swipe"
    ]

    private let gridColumns = [
        GridItem(.adaptive(minimum: 96), spacing: 10)
    ]

    init() {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains("-resetShareSetupState") {
            ShareSetupState.reset()
        }

        if arguments.contains("-markShareExtensionUsed") {
            ShareSetupState.markShareExtensionUsed()
        }

        let photos = arguments.contains("-uiTestingDemoSet")
            ? DemoPhotoFactory.makePhotos()
            : []
        _selectedPhotos = State(initialValue: photos)
        _hasCompletedShareSetup = State(initialValue: ShareSetupState.hasUsedShareExtension)
    }

    var body: some View {
        VStack(spacing: 0) {
            if selectedPhotos.isEmpty {
                if hasCompletedShareSetup {
                    readyState
                } else {
                    emptyState
                }
            } else {
                selectedGrid
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !selectedPhotos.isEmpty {
                bottomBar
            }
        }
        .fullScreenCover(isPresented: $isViewerPresented) {
            HandoffViewer(photos: selectedPhotos) {
                isViewerPresented = false
            }
        }
        .onAppear {
            hasCompletedShareSetup = ShareSetupState.hasUsedShareExtension
        }
    }

    private var emptyState: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    ShareSheetOnboardingAnimation()
                        .padding(.top, 6)

                    VStack(alignment: .leading, spacing: 24) {
                        Text(onboardingTitle)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("onboardingTitle")

                        VStack(alignment: .leading, spacing: 18) {
                            ForEach(Array(onboardingInstructions.enumerated()), id: \.offset) { index, instruction in
                                setupStep(number: index + 1, title: instruction)
                            }
                        }
                        .accessibilityIdentifier("onboardingSteps")
                    }

                    Spacer(minLength: 32)

                    Button {
                        openPhotos()
                    } label: {
                        Text("Open Photos")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 62)
                            .background(.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("openPhotosButton")
                }
                .frame(minHeight: proxy.size.height, alignment: .top)
                .padding(18)
            }
        }
        .background(Color(red: 0.11, green: 0.11, blue: 0.11))
    }

    private var readyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.green)

            Text("Ready in Photos")
                .font(.title2.weight(.bold))

            Text("Select photos, tap Share, then choose Don't Swipe.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(Color(uiColor: .systemGroupedBackground))
        .accessibilityIdentifier("setupCompleteState")
    }

    private var selectedGrid: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(selectedPhotos) { photo in
                    Image(uiImage: photo.image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 118)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .clipped()
                        .accessibilityLabel("Selected photo")
                }
            }
            .padding(16)
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 10) {
            Button {
                isViewerPresented = true
            } label: {
                Label("Open Don't Swipe", systemImage: "lock.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityIdentifier("startHandoffButton")
            .disabled(selectedPhotos.isEmpty)

            Text("\(selectedPhotos.count) selected")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("selectedCountLabel")
        }
        .padding(16)
        .background(.bar)
    }

    private func setupStep(number: Int, title: String) -> some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.title3.weight(.medium))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(.white.opacity(0.08), in: Circle())
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                }

            Text(title)
                .font(.title3.weight(.regular))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func openPhotos() {
        guard let url = URL(string: "photos-redirect://") else { return }
        openURL(url)
    }
}

#Preview {
    ContentView()
}
