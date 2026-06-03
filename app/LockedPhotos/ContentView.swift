import SwiftUI

struct ContentView: View {
    @State private var selectedPhotos: [SelectedPhoto] = []
    @State private var isViewerPresented = false
    @State private var hasCompletedShareSetup: Bool

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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ShareSheetOnboardingAnimation()
                    .padding(.top, 4)

                VStack(alignment: .leading, spacing: 9) {
                    setupStep(number: 1, title: "In Photos, select photos and tap Share")
                    setupStep(number: 2, title: "Tap More in the app row")
                    setupStep(number: 3, title: "Tap Edit")
                    setupStep(number: 4, title: "Tap + next to Don't Swipe")
                    setupStep(number: 5, title: "Confirm Don't Swipe is in Favorites")
                    setupStep(number: 6, title: "Tap Done, then Don't Swipe")
                }
                .accessibilityIdentifier("onboardingSteps")
            }
                .padding(18)
        }
        .background(Color(uiColor: .systemGroupedBackground))
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
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .frame(width: 26, height: 26)
                .background(.quaternary, in: Circle())

            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    ContentView()
}
