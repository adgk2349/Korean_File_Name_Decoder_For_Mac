//
//  FileProcessor.swift
//  KDecoder
//
//  Created by Seung Min Lee on 3/2/26.
//

import Foundation

/// 파일 처리 결과를 나타내는 모델
struct FileProcessResult {
    let successCount: Int
    let skipCount: Int
    let errorMessages: [String]

    var summary: String {
        "성공: \(successCount)개, 스킵: \(skipCount)개"
    }

    var hasErrors: Bool {
        !errorMessages.isEmpty
    }
}

/// 파일 이름 디코딩 및 이동 처리를 담당하는 모델
struct FileProcessor {

    private let fileManager = FileManager.default

    /// 파일 URL 배열을 받아 디코딩 + 이동 처리
    func processFiles(urls: [URL], saveToDesktop: Bool) -> FileProcessResult {
        var successCount = 0
        var skipCount = 0
        var errorMessages = [String]()

        guard !urls.isEmpty else {
            return FileProcessResult(successCount: 0, skipCount: 0, errorMessages: [])
        }

        let desktopURL = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first!

        for url in urls {
            let accessStarted = url.startAccessingSecurityScopedResource()
            defer {
                if accessStarted {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let originalName = url.lastPathComponent
            let decodedName = originalName.removingPercentEncoding ?? originalName
            let normalizedName = decodedName.precomposedStringWithCanonicalMapping

            let targetDirectory = saveToDesktop ? desktopURL : url.deletingLastPathComponent()
            var targetURL = targetDirectory.appendingPathComponent(normalizedName)

            // 이름이 동일하고 같은 위치면 스킵
            if url == targetURL && !saveToDesktop {
                skipCount += 1
                continue
            }

            // 파일명 충돌 시 _copy1, _copy2 ... 처리
            var counter = 1
            while fileManager.fileExists(atPath: targetURL.path) && targetURL != url {
                let nameWithoutExtension = (normalizedName as NSString).deletingPathExtension
                let fileExtension = (normalizedName as NSString).pathExtension
                let newName = "\(nameWithoutExtension)_copy\(counter).\(fileExtension)"
                targetURL = targetDirectory.appendingPathComponent(newName)
                counter += 1
            }

            do {
                try fileManager.moveItem(at: url, to: targetURL)
                successCount += 1
            } catch {
                let errorDesc = error.localizedDescription
                if errorMessages.count < 3 {
                    errorMessages.append(" - \(originalName): \(errorDesc)")
                }
            }
        }

        return FileProcessResult(
            successCount: successCount,
            skipCount: skipCount,
            errorMessages: errorMessages
        )
    }
}
