//
//  String+Date.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 21/9/24.
//

import Foundation

extension String {
    var date: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = NSLocale.current
        return dateFormatter.date(from: self)
    }
}
