//
//  BookmarkManager.swift
//  KDecoder
//
//  Created by Seung Min Lee on 3/2/26.
//

import Foundation
import AppKit

/// Security-Scoped Bookmark을 통해 폴더 접근 권한을 저장/복원하는 매니저
final class BookmarkManager {

    static let shared = BookmarkManager()

    private let bookmarkKey = "rootFolderBookmark"
    private var accessedURL: URL?

    private init() {}

    // MARK: - 저장된 북마크가 있는지 확인

    var hasBookmark: Bool {
        UserDefaults.standard.data(forKey: bookmarkKey) != nil
    }

    // MARK: - 사용자에게 폴더 선택 요청 후 북마크 저장

    /// 루트 폴더("/") 선택을 유도하는 NSOpenPanel을 띄우고, 선택된 폴더를 북마크로 저장
    /// - Returns: 사용자가 폴더를 선택하면 true, 취소하면 false
    @discardableResult
    func requestAccess() -> Bool {
        let panel = NSOpenPanel()
        panel.message = "KDecoder가 파일 이름을 변경하려면 폴더 접근 권한이 필요합니다.\n접근을 허용할 최상위 폴더를 선택해주세요."
        panel.prompt = "접근 허용"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(fileURLWithPath: "/")

        guard panel.runModal() == .OK, let url = panel.url else {
            return false
        }

        return saveBookmark(for: url)
    }

    // MARK: - 저장된 북마크로 접근 시작

    /// 저장된 북마크에서 URL을 복원하고 접근 시작
    /// - Returns: 접근이 시작되면 true
    @discardableResult
    func startAccess() -> Bool {
        guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
            return false
        }

        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            if isStale {
                // 북마크가 오래되었으면 다시 저장
                _ = saveBookmark(for: url)
            }

            if url.startAccessingSecurityScopedResource() {
                accessedURL = url
                return true
            }
        } catch {
            print("BookmarkManager: 북마크 복원 실패 - \(error.localizedDescription)")
        }

        return false
    }

    // MARK: - 접근 중단

    func stopAccess() {
        accessedURL?.stopAccessingSecurityScopedResource()
        accessedURL = nil
    }

    // MARK: - 북마크 초기화

    func clearBookmark() {
        stopAccess()
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
    }

    // MARK: - Private

    private func saveBookmark(for url: URL) -> Bool {
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)
            return true
        } catch {
            print("BookmarkManager: 북마크 저장 실패 - \(error.localizedDescription)")
            return false
        }
    }
}
