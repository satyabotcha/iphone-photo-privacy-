import SwiftUI
import UIKit

struct ShareSheetOnboardingAnimation: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase = 0

    private let phaseCount = 6
    private let demoImages = DemoPhotoFactory.makePhotos().map(\.image)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))

            ZStack(alignment: .bottom) {
                if phase == 5 {
                    lockedViewer
                        .transition(.opacity)
                } else {
                    photosScreen
                        .transition(.opacity)

                    if phase == 1 || phase == 4 {
                        shareSheet(readyToLaunch: phase == 4)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if phase == 2 || phase == 3 {
                        editAppsSheet(isAdded: phase == 3)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .padding(8)
        }
        .frame(height: 300)
        .clipped()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Animated setup preview showing Photos, Share, More, add Don't Swipe, and open the locked viewer")
        .accessibilityIdentifier("shareSetupAnimation")
        .task {
            guard !reduceMotion else {
                phase = 4
                return
            }

            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_250_000_000)
                withAnimation(.snappy(duration: 0.45)) {
                    phase = (phase + 1) % phaseCount
                }
            }
        }
    }

    private var photosScreen: some View {
        VStack(spacing: 6) {
            mockStatusBar

            HStack {
                Text("Photos")
                    .font(.title2.weight(.bold))

                Spacer()

                Text("Select")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal, 16)

            photoGrid
                .frame(height: 150)
                .clipped()

            Spacer(minLength: 0)

            HStack {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 46, height: 46)
                    .background(.blue.opacity(phase == 0 ? 0.16 : 0), in: Circle())
                    .overlay {
                        if phase == 0 {
                            tapPulse
                        }
                    }

                Spacer()

                Text("3 Selected")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: "trash")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 46, height: 46)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color(uiColor: .systemBackground))
    }

    private var mockStatusBar: some View {
        HStack {
            Text("10:51")
                .font(.caption.weight(.semibold))

            Spacer()

            Image(systemName: "wifi")
            Image(systemName: "battery.75percent")
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .foregroundStyle(.primary)
    }

    private var photoGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) {
            ForEach(0..<9) { index in
                Image(uiImage: demoImage(at: index))
                    .resizable()
                    .scaledToFill()
                    .overlay(alignment: .topTrailing) {
                        if index == 1 || index == 2 || index == 4 {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3.weight(.semibold))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .blue)
                            .padding(6)
                        }
                    }
                    .aspectRatio(0.82, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .padding(.horizontal, 16)
    }

    private func shareSheet(readyToLaunch: Bool) -> some View {
        VStack(spacing: 10) {
            Capsule()
                .fill(.secondary.opacity(0.32))
                .frame(width: 40, height: 5)

            HStack {
                Text("3 Photos Selected")
                    .font(.headline)

                Spacer()

                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                shareAppIcon("message.fill", title: "Messages", color: .green)
                shareAppIcon("envelope.fill", title: "Mail", color: .blue)

                if readyToLaunch {
                    dontSwipeIcon(isHighlighted: true)
                } else {
                    shareAppIcon("ellipsis", title: "More", color: .gray, isHighlighted: true)
                }

                shareAppIcon("eye.fill", title: "Preview", color: .indigo)
            }
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(10)
    }

    private func editAppsSheet(isAdded: Bool) -> some View {
        VStack(spacing: 10) {
            HStack {
                ButtonLabel("Cancel", color: .secondary)
                Spacer()
                Text("Apps")
                    .font(.headline)
                Spacer()
                ButtonLabel("Done", color: .blue)
                    .background {
                        if isAdded {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.blue.opacity(0.14))
                        }
                    }
            }

            Divider()

            HStack(spacing: 12) {
                Image(systemName: "lock.rectangle.stack.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(.black, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Don't Swipe")
                        .font(.body.weight(.semibold))
                    Text(isAdded ? "Favorite" : "Add to Favorites")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(isAdded ? .green : .blue)
                    .overlay {
                        if !isAdded {
                            tapPulse
                        }
                    }
            }
            .padding(12)
            .background(Color(uiColor: .tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(14)
        .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(10)
    }

    private var lockedViewer: some View {
        VStack(spacing: 0) {
            mockStatusBar
                .foregroundStyle(.white)

            HStack {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.16), in: Circle())

                Spacer()

                VStack(spacing: 1) {
                    Text("Don't Swipe")
                        .font(.headline)
                    Text("Only selected photos")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.64))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(.white.opacity(0.16), in: Capsule())

                Spacer()

                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .foregroundStyle(.white)

            Spacer()

            Image(uiImage: demoImage(at: 1))
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .clipped()
                .overlay {
                    Image(systemName: "lock.shield.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.9))
                }

            Spacer()

            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Image(uiImage: demoImage(at: index))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 42)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .overlay {
                            if index == 0 {
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .stroke(.white, lineWidth: 2)
                            }
                        }
                }
            }
            .padding(.bottom, 24)
        }
        .background(.black)
    }

    private func shareAppIcon(_ systemImage: String, title: String, color: Color, isHighlighted: Bool = false) -> some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    if isHighlighted {
                        tapPulse
                    }
                }

            Text(title)
                .font(.caption2)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private func dontSwipeIcon(isHighlighted: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: "lock.rectangle.stack.fill")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                .background(.black, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    if isHighlighted {
                        tapPulse
                    }
                }

            Text("Don't Swipe")
                .font(.caption2)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
    }

    private var tapPulse: some View {
        Circle()
            .stroke(.blue, lineWidth: 3)
            .frame(width: 62, height: 62)
            .shadow(color: .blue.opacity(0.35), radius: 10)
    }

    private func demoImage(at index: Int) -> UIImage {
        guard !demoImages.isEmpty else { return UIImage() }
        return demoImages[index % demoImages.count]
    }
}

private struct ButtonLabel: View {
    let title: String
    let color: Color

    init(_ title: String, color: Color) {
        self.title = title
        self.color = color
    }

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(color)
            .frame(width: 58, height: 32)
    }
}

#Preview {
    ShareSheetOnboardingAnimation()
        .padding()
}
