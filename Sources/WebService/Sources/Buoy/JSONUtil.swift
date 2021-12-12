//
// This source file is part of the FA2021 open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

let mountDir = URL(fileURLWithPath: "/buoy")

func readJSONFromFile<T>(_ type: T.Type, filePath: String) -> T? where T: Decodable {
    readJSONFromFile(type, fileURL: mountDir.appendingPathComponent(filePath))
}

func readJSONFromFile<T>(_ type: T.Type, fileURL: URL) -> T? where T: Decodable {
    guard let data = try? Data(contentsOf: fileURL) else {
        return nil
    }
    return try? JSONDecoder().decode(T.self, from: data)
}

func readJSONDirectory<T>(_ type: T.Type, dirPath: String) -> [T] where T: Decodable {
    guard let files = try? FileManager.default.contentsOfDirectory(at: mountDir.appendingPathComponent(dirPath),
                                                                   includingPropertiesForKeys: nil)
    else {
        return []
    }
    return files.compactMap {fileURL in
        readJSONFromFile(T.self, fileURL: fileURL)
    }
}
