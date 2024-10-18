//
//  Double+Formatter.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 18/10/24.
//

import Foundation

extension Double {
    var plottable: String {
        guard floor(self) == self else {
            return String(format: "%.4f", self).trimmingCharacters(in: CharacterSet(charactersIn: "0").inverted)
        }
        return String(format: "%.0f", self)
    }
}
