//
//  KDecoderApp.swift
//  KDecoder
//
//  Created by Seung Min Lee on 3/2/26.
//

import SwiftUI

@main
struct KDecoderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    NotificationCenter.default.post(
                        name: NSNotification.Name("OpenFiles"),
                        object: nil,
                        userInfo: ["urls": [url]]
                    )
                }
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("KDecoder 정보...") {
                    if let delegate = NSApp.delegate as? AppDelegate {
                        delegate.showAboutPanel(nil)
                    }
                }
            }
        }
    }
}
