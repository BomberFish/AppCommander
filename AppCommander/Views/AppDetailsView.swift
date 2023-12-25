// bomberfish
// AppDetailsView.swift – AppCommander
// created on 2023-12-22

import SwiftUI

struct AppDetailsView: View {
    public var app: Application
    var body: some View {
        List {
            InfoCell(title: "Name", value: app.name)
            InfoCell(title: "Bundle ID", value: app.bundleIdentifier)
            InfoCell(title: "Version", value: app.version)
            if let proxy = app.rawProxy {
                InfoCell(title: "App Type", value: proxy.applicationType)
                InfoCell(title: "Executable Path", value: proxy.canonicalExecutablePath)
                NavigationLink(destination: EntitlementsView(dict: proxy.entitlements)) {
                    Label("Entitlements", systemImage: "checkmark.seal")
                }
            }
        }
        .navigationTitle("Info")
    }
}

struct EntitlementsView: View {
    var dict: [String : Any]
    var body: some View {
        List {
            ForEach(Array(dict.keys), id: \.self) { key in
                InfoCell(title: key , value: "\(dict[key] ?? "")")
            }
        }
    }
}


struct InfoCell: View {
    public var title: String
    public var value: String
    var body: some View {
        HStack {
            Text(title)
                .multilineTextAlignment(.leading)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Entitlements")
    }
}
