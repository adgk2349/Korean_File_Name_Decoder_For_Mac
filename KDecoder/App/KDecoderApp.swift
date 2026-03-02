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
    }
}
