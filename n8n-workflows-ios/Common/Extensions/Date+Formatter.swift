//
//  Date+Formatter.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 21/9/24.
//

import Foundation

extension Date {
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        return dateFormatter.string(from: self)
    }
    
    var timeAgoDisplay: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var timeToDouble: Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self)
        
        guard let hour = components.hour, let minute = components.minute else {
            return 0.0
        }
        let minuteAsFraction = Double(minute) / 60.0
        return Double(hour) + minuteAsFraction
    }
}
