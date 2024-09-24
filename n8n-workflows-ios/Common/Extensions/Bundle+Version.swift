//
//  Bundle+Version.swift
//  n8n-workflows-ios
//
//  Created by Marcelino on 24/9/24.
//

import Foundation

extension Bundle {
    
    func appVersion() -> String? {
        guard let dictionary = infoDictionary, let version = dictionary["CFBundleShortVersionString"] as? String, let build = dictionary["CFBundleVersion"] as? String else {
            return nil
        }
        return "v\(version) (\(build))"
    }
}
