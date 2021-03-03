import Foundation

public extension DateFormatter {
    static var iso3339Formatter: DateFormatter {
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        fullDateFormatter.locale = Locale(identifier: "en_GB")
        return fullDateFormatter
    }
}
