//
//  AppDelegate.swift
//  KDecoder
//
//  Created by Seung Min Lee on 3/2/26.
//

import SwiftUI

/// 메뉴 바 아이콘 및 팝오버 관리를 담당하는 AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var dragView: StatusItemDragView?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 0. 메뉴바 전용 앱으로 설정 (Dock 아이콘 숨김)
        NSApp.setActivationPolicy(.accessory)

        // 1. 저장된 북마크로 폴더 접근 권한 복원
        BookmarkManager.shared.startAccess()

        // 1. NSPopover 초기화 (투명 배경)
        let contentView = ContentView()
        let hostingController = NSHostingController(rootView: contentView)
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = .clear

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 450, height: 450)
        popover.behavior = .transient
        popover.contentViewController = hostingController

        // 팝오버가 표시될 때 배경을 투명하게 설정
        NotificationCenter.default.addObserver(
            forName: NSPopover.willShowNotification,
            object: popover,
            queue: .main
        ) { _ in
            DispatchQueue.main.async {
                if let popoverWindow = hostingController.view.window {
                    popoverWindow.isOpaque = false
                    popoverWindow.backgroundColor = .clear
                }
            }
        }

        self.popover = popover

        // 2. NSStatusItem (메뉴 바 아이콘) 생성
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "k.circle.fill", accessibilityDescription: "KDecoder")
            button.action = #selector(togglePopover(_:))

            // 드래그 감지를 위한 커스텀 뷰 추가
            let dragView = StatusItemDragView(frame: button.bounds)
            dragView.onDragEntered = { [weak self] in
                self?.showPopoverDirectly()
            }
            dragView.onDragExited = { [weak self] in
                self?.hidePopoverDirectly()
            }
            button.addSubview(dragView)
            self.dragView = dragView

            // Auto Layout 설정
            dragView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dragView.topAnchor.constraint(equalTo: button.topAnchor),
                dragView.bottomAnchor.constraint(equalTo: button.bottomAnchor),
                dragView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                dragView.trailingAnchor.constraint(equalTo: button.trailingAnchor)
            ])
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(sender)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover?.contentViewController?.view.window?.makeKey()
            }
        }
    }

    static func showPopover() {
        if let delegate = NSApp.delegate as? AppDelegate {
            delegate.showPopoverDirectly()
        }
    }

    func showPopoverDirectly() {
        if let button = statusItem?.button, popover?.isShown == false {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func hidePopoverDirectly() {
        if popover?.isShown == true {
            popover?.performClose(nil)
        }
    }

    // 창 닫아도 앱 종료 안 되게 (메뉴바 유지)
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    // MARK: - 커스텀 About 창

    private var aboutWindow: NSWindow?

    @objc func showAboutPanel(_ sender: Any?) {
        if let existing = aboutWindow, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let hostingController = NSHostingController(rootView: AboutView())
        let window = NSWindow(contentViewController: hostingController)
        window.title = "KDecoder 정보"
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.center()
        window.setContentSize(hostingController.view.fittingSize)
        window.makeKeyAndOrderFront(nil)
        self.aboutWindow = window
    }
}
