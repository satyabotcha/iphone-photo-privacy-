import UniformTypeIdentifiers
import UIKit

struct SharedPhotoLoader {
    let extensionContext: NSExtensionContext?

    func loadPhotos() async throws -> [SelectedPhoto] {
        let providers = imageProviders()
        var photos: [SelectedPhoto] = []

        for provider in providers {
            if let photo = try await loadPhoto(from: provider) {
                photos.append(photo)
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

    private func loadPhoto(from provider: NSItemProvider) async throws -> SelectedPhoto? {
        if let data = try await loadImageData(from: provider),
           let image = UIImage(data: data) {
            return SelectedPhoto(image: image, info: PhotoInfo.make(fromImageData: data))
        }

        guard provider.canLoadObject(ofClass: UIImage.self) else { return nil }

        return try await withCheckedThrowingContinuation { continuation in
            _ = provider.loadObject(ofClass: UIImage.self) { object, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let image = object as? UIImage {
                    continuation.resume(returning: SelectedPhoto(image: image))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private func loadImageData(from provider: NSItemProvider) async throws -> Data? {
        guard provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) else { return nil }

        return try await withCheckedThrowingContinuation { continuation in
            provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: data)
                }
            }
        }
    }
}
