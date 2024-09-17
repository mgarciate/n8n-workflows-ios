//
//  SettingsViewModelProtocol.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 17/9/24.
//


import SwiftUI

protocol SettingsViewModelProtocol: ObservableObject {
    var apiKey: String { get set }
    var apiKeyBinding: Binding<String> { get }
}
