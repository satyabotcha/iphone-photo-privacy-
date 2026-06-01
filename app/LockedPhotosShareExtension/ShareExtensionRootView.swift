import SwiftUI

struct ShareExtensionRootView: View {
    let loader: SharedPhotoLoader
    let onDone: () -> Void
    let onCancel: () -> Void

    @State private var photos: [SelectedPhoto] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let errorMessage {
                errorView(message: errorMessage)
            } else {
                HandoffViewer(photos: photos, onEnd: onDone)
            }
        }
        .task {
            await loadPhotos()
        }
    }

    private var loadingView: some View {
        NavigationStack {
            VStack(spacing: 18) {
                ProgressView()
                Text("Preparing photos")
                    .font(.headline)
                Text("Only the photos shared from Photos are visible in Don't Swipe.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }

    private func errorView(message: String) -> some View {
        NavigationStack {
            ContentUnavailableView {
                Label("No Photos", systemImage: "photo.on.rectangle.angled")
            } description: {
                Text(message)
            } actions: {
                Button("Done", action: onDone)
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private func loadPhotos() async {
        do {
            let loadedPhotos = try await loader.loadPhotos()
            photos = loadedPhotos
            errorMessage = loadedPhotos.isEmpty ? "Share one or more photos from the Photos app." : nil
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
