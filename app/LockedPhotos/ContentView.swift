import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var selectedPhotos: [SelectedPhoto] = []
    @State private var isLoadingSelection = false
    @State private var isViewerPresented = false

    private let gridColumns = [
        GridItem(.adaptive(minimum: 96), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if selectedPhotos.isEmpty {
                    emptyState
                } else {
                    selectedGrid
                }
            }
            .navigationTitle("Don't Swipe")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Demo") {
                        selectedPhotos = DemoPhotoFactory.makePhotos()
                    }
                    .accessibilityIdentifier("demoToolbarButton")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    PhotosPicker(
                        selection: $pickerItems,
                        maxSelectionCount: 20,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Select", systemImage: "photo.badge.plus")
                    }
                    .disabled(isLoadingSelection)
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomBar
            }
            .task(id: pickerItems) {
                await loadSelectedPhotos()
            }
            .fullScreenCover(isPresented: $isViewerPresented) {
                HandoffViewer(photos: selectedPhotos) {
                    isViewerPresented = false
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Choose Photos", systemImage: "lock.rectangle.stack")
        } description: {
            Text("Only the photos you choose are visible in Don't Swipe.")
        } actions: {
            VStack(spacing: 12) {
                PhotosPicker(
                    selection: $pickerItems,
                    maxSelectionCount: 20,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Select Photos", systemImage: "photo.on.rectangle.angled")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    selectedPhotos = DemoPhotoFactory.makePhotos()
                } label: {
                    Label("Use Demo Set", systemImage: "sparkles")
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("useDemoSetButton")
            }
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
            if isLoadingSelection {
                ProgressView("Preparing selected photos")
            }

            Button {
                isViewerPresented = true
            } label: {
                Label("Open Don't Swipe", systemImage: "lock.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityIdentifier("startHandoffButton")
            .disabled(selectedPhotos.isEmpty || isLoadingSelection)

            Text("\(selectedPhotos.count) selected")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("selectedCountLabel")
        }
        .padding(16)
        .background(.bar)
    }

    private func loadSelectedPhotos() async {
        guard !pickerItems.isEmpty else { return }

        isLoadingSelection = true
        defer { isLoadingSelection = false }

        var loadedPhotos: [SelectedPhoto] = []

        for item in pickerItems {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                continue
            }

            loadedPhotos.append(SelectedPhoto(image: image, info: PhotoInfo.make(fromImageData: data)))
        }

        selectedPhotos = loadedPhotos
    }
}

#Preview {
    ContentView()
}
