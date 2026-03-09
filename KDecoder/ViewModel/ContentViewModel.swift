//
//  ContentViewModel.swift
//  KDecoder
//
//  Created by adgk2349 on 3/2/26.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

/// ContentView의 상태 관리 및 비즈니스 로직을 담당하는 ViewModel
@MainActor
final class ContentViewModel: ObservableObject {

    // MARK: - Published 상태

    @Published var saveToDesktop = false
    @Published var isTargeted = false
    @Published var resultMessage = "파일을 이곳으로 끌어다 놓으세요"
    @Published var hasAccess: Bool = BookmarkManager.shared.hasBookmark

    // MARK: - 의존성

    private let fileProcessor = FileProcessor()

    // MARK: - 파일 직접 선택

    func selectFilesManually() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        if panel.runModal() == .OK {
            handleFiles(urls: panel.urls)
        }
    }

    // MARK: - 드래그 앤 드롭 처리

    func processDroppedFiles(providers: [NSItemProvider]) {
        var urls: [URL] = []
        let group = DispatchGroup()
        let lock = NSLock()

        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, error) in
                    if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        lock.lock()
                        urls.append(url)
                        lock.unlock()
                    } else if let url = item as? URL {
                        lock.lock()
                        urls.append(url)
                        lock.unlock()
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.handleFiles(urls: urls)
        }
    }

    // MARK: - URL 알림을 통한 파일 처리

    func handleOpenFilesNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let urls = userInfo["urls"] as? [URL] {
            AppDelegate.showPopover()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.handleFiles(urls: urls)
            }
        }
    }

    // MARK: - 폴더 접근 권한 요청

    /// 저장된 북마크가 없으면 사용자에게 폴더 접근 권한을 요청
    func requestAccessIfNeeded() {
        let manager = BookmarkManager.shared
        if !manager.hasBookmark {
            if manager.requestAccess() {
                manager.startAccess()
                hasAccess = true
            }
        }
    }

    // MARK: - Private

    private func handleFiles(urls: [URL]) {
        // 북마크가 없으면 먼저 권한 요청
        if !BookmarkManager.shared.hasBookmark {
            requestAccessIfNeeded()
        }

        let result = fileProcessor.processFiles(urls: urls, saveToDesktop: saveToDesktop)

        if result.hasErrors {
            showErrorAlert(result: result)
        }

        resultMessage = result.summary
    }

    private func showErrorAlert(result: FileProcessResult) {
        let alert = NSAlert()
        alert.messageText = "작업 완료 (오류 발생)"
        var infoText = "\(result.successCount)개의 파일이 성공적으로 처리되었습니다.\n(스킵된 파일: \(result.skipCount)개)"
        infoText += "\n\n[실패 내역 일부]\n" + result.errorMessages.joined(separator: "\n")
        infoText += "\n\n💡 파일을 옮기지 못한 경우, 폴더 접근 권한을 다시 설정해주세요."
        alert.informativeText = infoText
        alert.alertStyle = .warning
        alert.addButton(withTitle: "확인")
        alert.addButton(withTitle: "폴더 권한 재설정")

        if alert.runModal() == .alertSecondButtonReturn {
            BookmarkManager.shared.clearBookmark()
            hasAccess = false
        }
    }
}
