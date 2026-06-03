import SwiftUI

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @State private var selectedPhotos: [SelectedPhoto] = []
    @State private var isViewerPresented = false
    @State private var isSetupGuidePresented = false
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
            let animationHeight = min(370, max(280, proxy.size.height * 0.48))

            VStack(alignment: .leading, spacing: 12) {
                ShareSheetOnboardingAnimation(previewHeight: animationHeight)

                VStack(alignment: .leading, spacing: 8) {
                    Text(onboardingTitle)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("onboardingTitle")

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(onboardingInstructions.enumerated()), id: \.offset) { index, instruction in
                            setupStep(number: index + 1, title: instruction)
                        }
                    }
                    .accessibilityIdentifier("onboardingSteps")
                }

                Spacer(minLength: 8)

                Button {
                    openPhotos()
                } label: {
                    Text("Open Photos")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("openPhotosButton")
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 14)
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
        }
        .background(Color(red: 0.11, green: 0.11, blue: 0.11))
    }

    private var readyState: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()

                Button {
                    isSetupGuidePresented = true
                } label: {
                    Label("Setup", systemImage: "questionmark.circle")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("showSetupGuideButton")
            }
            .padding([.horizontal, .top], 20)

            Spacer()

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
            .padding(24)
            .accessibilityIdentifier("setupCompleteState")

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .fullScreenCover(isPresented: $isSetupGuidePresented) {
            setupGuide
        }
    }

    private var setupGuide: some View {
        ZStack(alignment: .topTrailing) {
            emptyState

            Button {
                isSetupGuidePresented = false
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(.white.opacity(0.12), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close setup guide")
            .accessibilityIdentifier("closeSetupGuideButton")
            .padding(.top, 14)
            .padding(.trailing, 18)
        }
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
        HStack(spacing: 9) {
            Text("\(number)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(.white.opacity(0.08), in: Circle())
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                }

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(height: 26)
    }

    private func openPhotos() {
        guard let url = URL(string: "photos-redirect://") else { return }
        openURL(url)
    }
}

#Preview {
    ContentView()
}
