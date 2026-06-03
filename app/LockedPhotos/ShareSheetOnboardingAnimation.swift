import SwiftUI
import UIKit

struct ShareSheetOnboardingAnimation: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: StoryPhase = .selectFirstPhoto

    private let demoImages = DemoPhotoFactory.makePhotos().map(\.image)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))

            ZStack(alignment: .bottom) {
                if phase == .lockedViewer {
                    lockedViewer
                        .transition(.opacity)
                } else {
                    photosScreen
                        .transition(.opacity)

                    if phase == .shareMore || phase == .launchDontSwipe {
                        shareSheet(readyToLaunch: phase == .launchDontSwipe)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if phase == .appsMore || phase == .editPlus || phase == .favoriteDone {
                        appsSheet
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .padding(8)
        }
        .frame(height: 340)
        .clipped()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Animated setup preview showing three photos selected, Share, More, Edit, add Don't Swipe to Favorites, Done, and open the locked viewer")
        .accessibilityIdentifier("shareSetupAnimation")
        .task {
            guard !reduceMotion else {
                phase = .favoriteDone
                return
            }

            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: phase.holdNanoseconds)
                withAnimation(.smooth(duration: 0.55)) {
                    phase = phase.next
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
                    .background(.blue.opacity(phase == .shareButton ? 0.16 : 0), in: Circle())
                    .overlay {
                        if phase == .shareButton {
                            tapPulse
                        }
                    }

                Spacer()

                Text("\(phase.selectedPhotoIndices.count) Selected")
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
                let isSelected = phase.selectedPhotoIndices.contains(index)
                let isCurrentTap = phase.tappingPhotoIndex == index

                Image(uiImage: demoImage(at: index))
                    .resizable()
                    .scaledToFill()
                    .overlay(alignment: .topTrailing) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3.weight(.semibold))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .blue)
                            .padding(6)
                            .overlay {
                                if isCurrentTap {
                                    tapPulse
                                        .scaleEffect(0.56)
                                }
                            }
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
                shareAppIcon("eye.fill", title: "Preview", color: .indigo)

                if readyToLaunch {
                    dontSwipeIcon(isHighlighted: true)
                } else {
                    shareAppIcon("ellipsis", title: "More", color: .gray, isHighlighted: true)
                }
            }
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(10)
    }

    private var appsSheet: some View {
        VStack(spacing: 11) {
            HStack {
                ButtonLabel(phase == .appsMore ? "Done" : "", color: .clear)
                Spacer()
                Text("Apps")
                    .font(.headline)
                Spacer()
                ButtonLabel(phase == .appsMore ? "Edit" : "Done", color: .blue)
                    .background {
                        if phase == .appsMore || phase == .favoriteDone {
                            Capsule()
                                .fill(.blue.opacity(0.14))
                        }
                    }
                    .overlay {
                        if phase == .appsMore || phase == .favoriteDone {
                            tapPulse
                                .scaleEffect(0.76)
                        }
                    }
            }

            VStack(alignment: .leading, spacing: 7) {
                sheetSectionTitle("Favorites")
                VStack(spacing: 0) {
                    appListRow(icon: "airplayaudio", title: "AirDrop", accent: .blue)
                    Divider()
                        .padding(.leading, 54)
                    if phase == .favoriteDone {
                        appListRow(
                            icon: "lock.rectangle.stack.fill",
                            title: "Don't Swipe",
                            accent: .black,
                            leading: "minus.circle.fill",
                            trailing: "line.3.horizontal"
                        )
                    } else {
                        appListRow(icon: "message.fill", title: "Messages", accent: .green)
                    }
                }
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            if phase != .favoriteDone {
                VStack(alignment: .leading, spacing: 7) {
                    sheetSectionTitle("Suggestions")
                    VStack(spacing: 0) {
                        appListRow(icon: "checklist", title: "Reminders", accent: .white, neutralIcon: true, leading: phase == .editPlus ? "plus.circle.fill" : nil)
                        Divider()
                            .padding(.leading, 54)
                        appListRow(
                            icon: "lock.rectangle.stack.fill",
                            title: "Don't Swipe",
                            accent: .black,
                            leading: phase == .editPlus ? "plus.circle.fill" : nil,
                            highlightLeading: phase == .editPlus
                        )
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .systemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(10)
    }

    private func sheetSectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.bold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
    }

    private func appListRow(
        icon: String,
        title: String,
        accent: Color,
        neutralIcon: Bool = false,
        leading: String? = nil,
        trailing: String? = nil,
        highlightLeading: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            if let leading {
                Image(systemName: leading)
                    .font(.title3.weight(.semibold))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(leading.contains("plus") ? .white : .white, leading.contains("plus") ? .green : .red)
                    .frame(width: 24, height: 24)
                    .overlay {
                        if highlightLeading {
                            tapPulse
                                .scaleEffect(0.62)
                        }
                    }
            }

            Image(systemName: icon)
                .font(.headline.weight(.semibold))
                .foregroundStyle(neutralIcon ? .gray : .white)
                .frame(width: 38, height: 38)
                .background(accent, in: RoundedRectangle(cornerRadius: 9, style: .continuous))

            Text(title)
                .font(.body.weight(.semibold))

            Spacer()

            if let trailing {
                Image(systemName: trailing)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 54)
        .padding(.horizontal, 10)
    }

    private enum StoryPhase: Int, CaseIterable {
        case selectFirstPhoto
        case selectSecondPhoto
        case selectThirdPhoto
        case shareButton
        case shareMore
        case appsMore
        case editPlus
        case favoriteDone
        case launchDontSwipe
        case lockedViewer

        var next: StoryPhase {
            let phases = Self.allCases
            let nextIndex = (rawValue + 1) % phases.count
            return phases[nextIndex]
        }

        var selectedPhotoIndices: Set<Int> {
            switch self {
            case .selectFirstPhoto:
                return [1]
            case .selectSecondPhoto:
                return [1, 2]
            case .selectThirdPhoto, .shareButton, .shareMore, .appsMore, .editPlus, .favoriteDone, .launchDontSwipe, .lockedViewer:
                return [1, 2, 4]
            }
        }

        var tappingPhotoIndex: Int? {
            switch self {
            case .selectFirstPhoto:
                return 1
            case .selectSecondPhoto:
                return 2
            case .selectThirdPhoto:
                return 4
            case .shareButton, .shareMore, .appsMore, .editPlus, .favoriteDone, .launchDontSwipe, .lockedViewer:
                return nil
            }
        }

        // These holds are intentionally slower than the transitions so first-run setup can be followed without pausing.
        var holdNanoseconds: UInt64 {
            switch self {
            case .selectFirstPhoto, .selectSecondPhoto:
                return 1_400_000_000
            case .selectThirdPhoto:
                return 1_700_000_000
            case .shareButton:
                return 2_400_000_000
            case .shareMore:
                return 3_300_000_000
            case .appsMore:
                return 3_000_000_000
            case .editPlus:
                return 3_700_000_000
            case .favoriteDone:
                return 3_400_000_000
            case .launchDontSwipe:
                return 2_800_000_000
            case .lockedViewer:
                return 2_200_000_000
            }
        }
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
