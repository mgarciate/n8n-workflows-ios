//
//  Project.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 15/10/24.
//

enum ProjectType: String, Codable {
    case personal, team
}

struct Project: Codable, Identifiable {
    static let allProjectsId = ""
    let id: String
    let name: String
    let type: ProjectType?
}

extension Project {
    static var allProjectsObject: Project {
        get {
            Project(id: Project.allProjectsId, name: "All", type: .team)
        }
    }
}
