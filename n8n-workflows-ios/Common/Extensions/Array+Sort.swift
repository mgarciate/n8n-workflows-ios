//
//  Array+Sort.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 20/12/24.
//

import Foundation

extension Array {
    func sortedByLocalizedString(_ keyPath: KeyPath<Element, String>, ascending: Bool = true) -> [Element] {
        sorted { lhs, rhs in
            let comparisonResult = lhs[keyPath: keyPath].localizedCompare(rhs[keyPath: keyPath])
            return ascending ? comparisonResult == .orderedAscending : comparisonResult == .orderedDescending
        }
    }
    
    func sortedByDateString(_ keyPath: KeyPath<Element, String>, ascending: Bool = true) -> [Element] {
        sorted { lhs, rhs in
            let lhsDate = lhs[keyPath: keyPath].date
            let rhsDate = rhs[keyPath: keyPath].date
            
            guard let lhsDate, let rhsDate else {
                return ascending ? lhsDate != nil : rhsDate != nil
            }
            
            return ascending ? lhsDate < rhsDate : lhsDate > rhsDate
        }
    }
}
