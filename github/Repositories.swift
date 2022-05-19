//
//  Repositories.swift
//  github
//
//  Created by 김두원 on 2022/05/08.
//

import Foundation

struct Results: Codable {
    let result: [Repositories]
}

struct Repositories: Codable {
    let total_count: Int
    let items: [Items]
}

struct Items: Codable {
    let full_name: String
    let name: String
    let language: String
    let html_url: String
    let description: String?
}
