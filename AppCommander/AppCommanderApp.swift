// bomberfish
// AppCommanderApp.swift – AppCommander
// created on 2023-12-21

import SwiftUI

var isTrollStore = false

@main
struct AppCommanderApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
//                .onAppear {
//                    if FileManager.default.isReadableFile(atPath: "/var/mobile") {
//                        isTrollStore = true
//                    }
//                }
        }
    }
}
