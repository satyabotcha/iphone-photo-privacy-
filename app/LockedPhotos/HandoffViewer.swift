import SwiftUI

struct HandoffViewer: View {
    let photos: [SelectedPhoto]
    let onEnd: () -> Void
    @State private var currentIndex = 0
    @State private var isChromeVisible = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    ZoomableImage(image: photo.image)
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
    }

    private var topControls: some View {
        HStack {
            Button {
                onEnd()
            } label: {
                Label("End", systemImage: "xmark")
                    .labelStyle(.iconOnly)
                    .frame(width: 44, height: 44)
                    .background(.black.opacity(0.55), in: Circle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .accessibilityLabel("End handoff")

            Spacer()

            Text("\(currentIndex + 1) / \(photos.count)")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.black.opacity(0.55), in: Capsule())
                .accessibilityLabel("Photo \(currentIndex + 1) of \(photos.count)")
                .accessibilityIdentifier("handoffCounter")
        }
        .padding()
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
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Show photo \(index + 1)")
                        .accessibilityIdentifier("handoffThumbnail_\(index + 1)")
                        .id(index)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .frame(height: 72)
            .background(.black.opacity(0.72))
            .accessibilityIdentifier("handoffThumbnailStrip")
            .onChange(of: currentIndex) { _, newIndex in
                withAnimation(.easeInOut(duration: 0.18)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }
}
