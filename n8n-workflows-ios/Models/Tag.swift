//
//  Tag.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 4/10/24.
//

import Foundation

struct Tag: Codable, Identifiable {
    let id: String
    let name: String
}

struct SelectableTag: Identifiable {
    let id = UUID().uuidString
    let tag: Tag
    var isSelected = false
}
