//
//  Untitled.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 20/9/24.
//

import Foundation

extension UserDefaults {
    func decode<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = self.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func encode<T: Encodable>(_ value: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value) {
            self.set(data, forKey: key)
        }
    }
}


