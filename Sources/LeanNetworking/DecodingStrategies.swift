//
//  File.swift
//  
//
//  Created by Oleksandr Glagoliev on 13.07.2020.
//

import Foundation


public extension DateFormatter {
    static var fullDateFormatter: DateFormatter {
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        fullDateFormatter.locale = Locale(identifier: "en_GB")
        return fullDateFormatter
    }
}
