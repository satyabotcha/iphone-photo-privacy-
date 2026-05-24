import UIKit

enum DemoPhotoFactory {
    static func makePhotos() -> [SelectedPhoto] {
        [
            makePhoto(title: "One", colors: [UIColor.systemIndigo, UIColor.systemTeal]),
            makePhoto(title: "Two", colors: [UIColor.systemPink, UIColor.systemOrange]),
            makePhoto(title: "Three", colors: [UIColor.systemGreen, UIColor.systemBlue])
        ]
    }

    private static func makePhoto(title: String, colors: [UIColor]) -> SelectedPhoto {
        let size = CGSize(width: 1200, height: 1600)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
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

        return SelectedPhoto(image: image)
    }
}
