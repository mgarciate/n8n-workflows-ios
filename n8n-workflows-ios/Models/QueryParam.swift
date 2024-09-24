//
//  QueryParam.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 24/9/24.
//

import SwiftUI

struct QueryParam: Identifiable {
    let id = UUID().uuidString
    var key: String
    var value: String
}
