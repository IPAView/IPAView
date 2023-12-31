//
//  IPAViewApp.swift
//  IPAView
//
//  Created by everettjf on 2023/12/23.
//

import SwiftUI
import SwiftData

@main
struct IPAViewApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Open Cache") {
                    let dir = Utils.getCacheDirectory()
                    Utils.revealInFinder(fileURL: dir)
                }
            }
            CommandGroup(replacing: .help) {
                Button("IPAView Help") {
                    Utils.openURL("https://ipaview.github.io/")
                }
            }
        }
    }
}
