//
//  DataResponse.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 12/9/24.
//

struct DataResponse<T: Codable>: Codable {
    @IgnoreFailure var data: [T]
    let nextCursor: String?
}
