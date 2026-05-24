import UniformTypeIdentifiers
import UIKit

struct SharedPhotoLoader {
    let extensionContext: NSExtensionContext?

    func loadPhotos() async throws -> [SelectedPhoto] {
        let providers = imageProviders()
        var photos: [SelectedPhoto] = []

        for provider in providers {
            if let image = try await loadImage(from: provider) {
                photos.append(SelectedPhoto(image: image))
            }
        }

        return photos
    }

    private func imageProviders() -> [NSItemProvider] {
        extensionContext?.inputItems
            .compactMap { $0 as? NSExtensionItem }
            .flatMap { $0.attachments ?? [] }
            .filter { provider in
                provider.hasItemConformingToTypeIdentifier(UTType.image.identifier)
            } ?? []
    }

    private func loadImage(from provider: NSItemProvider) async throws -> UIImage? {
        if provider.canLoadObject(ofClass: UIImage.self) {
            return try await withCheckedThrowingContinuation { continuation in
                _ = provider.loadObject(ofClass: UIImage.self) { object, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: object as? UIImage)
                    }
                }
            }
        }

        return try await withCheckedThrowingContinuation { continuation in
            provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let data {
                    continuation.resume(returning: UIImage(data: data))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
