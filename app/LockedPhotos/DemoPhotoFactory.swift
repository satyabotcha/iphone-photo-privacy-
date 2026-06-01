import UIKit

enum DemoPhotoFactory {
    static func makePhotos() -> [SelectedPhoto] {
        [
            makePhoto(assetName: "DemoPhoto1", dayOffset: 0),
            makePhoto(assetName: "DemoPhoto2", dayOffset: -1),
            makePhoto(assetName: "DemoPhoto3", dayOffset: -2)
        ]
    }

    private static func makePhoto(assetName: String, dayOffset: Int) -> SelectedPhoto {
        SelectedPhoto(
            image: UIImage(named: assetName) ?? makeFallbackImage(),
            info: PhotoInfo(
                capturedAt: Calendar.current.date(byAdding: .day, value: dayOffset, to: .now),
                latitude: 51.5072,
                longitude: -0.1276
            )
        )
    }

    private static func makeFallbackImage() -> UIImage {
        makeGradientImage(title: "Photo", colors: [UIColor.systemIndigo, UIColor.systemTeal])
    }

    private static func makeGradientImage(title: String, colors: [UIColor]) -> UIImage {
        let size = CGSize(width: 1200, height: 1600)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let cgColors = colors.map(\.cgColor) as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: cgColors,
                locations: [0, 1]
            )

            if let gradient {
                context.cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )
            }

            UIColor.white.withAlphaComponent(0.18).setFill()
            UIBezierPath(ovalIn: CGRect(x: 130, y: 180, width: 360, height: 360)).fill()
            UIBezierPath(roundedRect: CGRect(x: 690, y: 920, width: 330, height: 430), cornerRadius: 72).fill()

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 128, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]

            NSString(string: title).draw(
                in: CGRect(x: 0, y: 690, width: size.width, height: 170),
                withAttributes: attributes
            )
        }
    }
}
