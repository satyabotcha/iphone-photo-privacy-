import ImageIO
import UIKit

struct SelectedPhoto: Identifiable {
    let id = UUID()
    let image: UIImage
    let info: PhotoInfo?

    init(image: UIImage, info: PhotoInfo? = nil) {
        self.image = image
        self.info = info
    }
}

struct PhotoInfo {
    private static let exifWallClockTimeZone = TimeZone(secondsFromGMT: 0)!

    let capturedAt: Date?
    let latitude: Double?
    let longitude: Double?
    let capturedAtDisplayTimeZone: TimeZone?

    init(
        capturedAt: Date?,
        latitude: Double?,
        longitude: Double?,
        capturedAtDisplayTimeZone: TimeZone? = nil
    ) {
        self.capturedAt = capturedAt
        self.latitude = latitude
        self.longitude = longitude
        self.capturedAtDisplayTimeZone = capturedAtDisplayTimeZone
    }

    var hasContent: Bool {
        capturedAt != nil || (latitude != nil && longitude != nil)
    }

    var dateTitleText: String? {
        guard let capturedAt else { return nil }

        return makeFormatter(format: "d MMMM yyyy").string(from: capturedAt)
    }

    var timeText: String? {
        guard let capturedAt else { return nil }

        let formatter = makeFormatter(format: "h:mm a")
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"

        return formatter.string(from: capturedAt)
    }

    var locationText: String? {
        guard let latitude, let longitude else { return nil }

        return String(format: "%.4f, %.4f", latitude, longitude)
    }

    static func make(fromImageData data: Data) -> PhotoInfo? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
            return nil
        }

        let capturedAt = makeCapturedDate(from: properties)
        let coordinate = makeCoordinate(from: properties)
        let info = PhotoInfo(
            capturedAt: capturedAt,
            latitude: coordinate?.latitude,
            longitude: coordinate?.longitude,
            capturedAtDisplayTimeZone: capturedAt == nil ? nil : exifWallClockTimeZone
        )

        return info.hasContent ? info : nil
    }

    private static func makeCapturedDate(from properties: [CFString: Any]) -> Date? {
        let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any]
        let tiff = properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any]

        let rawDate = exif?[kCGImagePropertyExifDateTimeOriginal] as? String
            ?? exif?[kCGImagePropertyExifDateTimeDigitized] as? String
            ?? tiff?[kCGImagePropertyTIFFDateTime] as? String

        guard let rawDate else { return nil }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        // EXIF DateTimeOriginal is a camera wall-clock value; do not shift it through the current timezone.
        formatter.timeZone = exifWallClockTimeZone
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"

        return formatter.date(from: rawDate)
    }

    private func makeFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = capturedAtDisplayTimeZone ?? .autoupdatingCurrent
        formatter.dateFormat = format

        return formatter
    }

    private static func makeCoordinate(from properties: [CFString: Any]) -> (latitude: Double, longitude: Double)? {
        guard let gps = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any],
              let rawLatitude = gps[kCGImagePropertyGPSLatitude] as? Double,
              let rawLongitude = gps[kCGImagePropertyGPSLongitude] as? Double else {
            return nil
        }

        let latitudeRef = gps[kCGImagePropertyGPSLatitudeRef] as? String
        let longitudeRef = gps[kCGImagePropertyGPSLongitudeRef] as? String

        let latitude = latitudeRef == "S" ? -rawLatitude : rawLatitude
        let longitude = longitudeRef == "W" ? -rawLongitude : rawLongitude

        return (latitude, longitude)
    }
}
