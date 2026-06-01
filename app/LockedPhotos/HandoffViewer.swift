import LocalAuthentication
import SwiftUI

struct HandoffViewer: View {
    let photos: [SelectedPhoto]
    let onEnd: () -> Void
    @State private var currentIndex = 0
    @State private var isChromeVisible = true
    @State private var isAuthenticatingToEnd = false

    private var canvasColor: UIColor {
        isChromeVisible ? .systemBackground : .black
    }

    private var currentPhoto: SelectedPhoto? {
        photos.indices.contains(currentIndex) ? photos[currentIndex] : nil
    }

    var body: some View {
        ZStack {
            Color(uiColor: canvasColor)
                .ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    ZoomableImage(image: photo.image, backgroundColor: canvasColor)
                        .ignoresSafeArea()
                        .tag(index)
                        .accessibilityLabel("Don't Swipe photo \(index + 1) of \(photos.count)")
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.18)) {
                    isChromeVisible.toggle()
                }
            }

            if isChromeVisible {
                VStack(spacing: 0) {
                    topControls

                    Spacer()

                    thumbnailStrip
                }
                .transition(.opacity)
            }
        }
        .statusBarHidden(!isChromeVisible)
        .preferredColorScheme(isChromeVisible ? .light : .dark)
        .animation(.easeInOut(duration: 0.18), value: isChromeVisible)
    }

    private var topControls: some View {
        HStack(alignment: .top, spacing: 10) {
            Button {
                Task {
                    await endHandoffAfterOwnerUnlock()
                }
            } label: {
                Label("End", systemImage: "chevron.left")
                    .labelStyle(.iconOnly)
                    .font(.title3.weight(.semibold))
                    .frame(width: 52, height: 52)
                    .background(.regularMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)
            .disabled(isAuthenticatingToEnd)
            .accessibilityLabel("Unlock to exit Don't Swipe")
            .accessibilityIdentifier("endHandoffButton")

            Spacer()

            if let info = currentPhoto?.info {
                photoInfo(info)
                    .frame(maxWidth: 280)
                    .layoutPriority(1)
            }

            Spacer()

            Color.clear
                .frame(width: 52, height: 52)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func photoInfo(_ info: PhotoInfo) -> some View {
        VStack(spacing: 2) {
            if let dateText = info.dateTitleText {
                Text(dateText)
                    .font(.callout.weight(.semibold))
                    .accessibilityIdentifier("photoInfoDateLabel")
            }

            if let timeText = info.timeText {
                Text(timeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("photoInfoTimeLabel")
            }
        }
        .foregroundStyle(.primary)
        .lineLimit(1)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: Capsule())
    }

    private var thumbnailStrip: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                            Button {
                                withAnimation(.easeInOut(duration: 0.18)) {
                                    currentIndex = index
                                }
                            } label: {
                                Image(uiImage: photo.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 34, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .stroke(index == currentIndex ? .white : .clear, lineWidth: 2)
                                            .shadow(color: .black.opacity(index == currentIndex ? 0.35 : 0), radius: 2, y: 1)
                                    }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Show photo \(index + 1)")
                            .accessibilityIdentifier("handoffThumbnail_\(index + 1)")
                            .id(index)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(minWidth: geometry.size.width, alignment: .center)
                }
                .frame(height: 70)
                .padding(.bottom, 16)
                .accessibilityIdentifier("handoffThumbnailStrip")
                .onChange(of: currentIndex) { _, newIndex in
                    withAnimation(.easeInOut(duration: 0.18)) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
            .frame(height: 86)
        }
    }

    @MainActor
    private func endHandoffAfterOwnerUnlock() async {
        guard !isAuthenticatingToEnd else { return }

        isAuthenticatingToEnd = true
        let isOwnerUnlocked = await HandoffExitAuthenticator.authenticateOwner()
        isAuthenticatingToEnd = false

        guard isOwnerUnlocked else { return }

        onEnd()
    }
}

private enum HandoffExitAuthenticator {
    static func authenticateOwner() async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return false
        }

        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Unlock to exit Don't Swipe and return to Photos."
            ) { success, _ in
                continuation.resume(returning: success)
            }
        }
    }
}
