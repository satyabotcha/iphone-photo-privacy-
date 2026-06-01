import SwiftUI

struct HandoffViewer: View {
    let photos: [SelectedPhoto]
    let onEnd: () -> Void
    @State private var currentIndex = 0
    @State private var isChromeVisible = true

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
                        .accessibilityLabel("Handoff photo \(index + 1) of \(photos.count)")
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
                onEnd()
            } label: {
                Label("End", systemImage: "chevron.left")
                    .labelStyle(.iconOnly)
                    .font(.title3.weight(.semibold))
                    .frame(width: 52, height: 52)
                    .background(.regularMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)
            .accessibilityLabel("End handoff")
            .accessibilityIdentifier("endHandoffButton")

            Spacer()

            if let info = currentPhoto?.info {
                photoInfo(info)
                    .frame(maxWidth: 280)
                    .layoutPriority(1)

                Spacer()
            }

            Text("\(currentIndex + 1) / \(photos.count)")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(minWidth: 52, minHeight: 52)
                .padding(.horizontal, 4)
                .background(.regularMaterial, in: Capsule())
                .accessibilityLabel("Photo \(currentIndex + 1) of \(photos.count)")
                .accessibilityIdentifier("handoffCounter")
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func photoInfo(_ info: PhotoInfo) -> some View {
        VStack(spacing: 2) {
            if let dateText = info.dateText {
                Text(dateText)
                    .font(.callout.weight(.semibold))
                    .accessibilityIdentifier("photoInfoDateLabel")
            }

            if let locationText = info.locationText {
                Text(locationText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("photoInfoLocationLabel")
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
    }
}
