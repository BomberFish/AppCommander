// bomberfish
// AppView.swift – AppCommander
// created on 2023-12-21

//import LaunchServicesBridge
import SwiftUI

struct AppView: View {
    public var app: Application

    @Environment(\.colorScheme) private var cs
    @State private var palette: Palette = .init()
    private var currentAccentColor: Color {
        return Color(uiColor: ((cs == .light ? palette.DarkMuted?.uiColor : palette.Vibrant?.uiColor) ?? UIColor(named: "AccentColor"))!)
    }

    var body: some View {
        List {
            Section {
                AppCell(app: app)
                
                Button("Open", systemImage: "arrow.up.right.square") {
                    if !app.open() {
                        Haptic.shared.notify(.error)
                        UIApplication.shared.alert(title: "Could not open \(app.name).", body: "")
                    }
                }
                NavigationLink(destination: AppDetailsView(app: app)) {
                    Label("More Info", systemImage: "info.circle")
                }
            }
            
            Section {
//                Button("Decrypt IPA", systemImage: "lock.open") {
//                    do {
//                        try Decryption.decrypt(app)
//                    } catch {
//                        UIApplication.shared.alert(body: error.localizedDescription)
//                    }
//                }
//                Button("Export Encrypted IPA", systemImage: "lock") {
//                    UIApplication.shared.alert(body: "not implemented")
//                }
                let isEncrypted = Decryption.isEncrypted(app)
                Button(isEncrypted ? "Decrypt IPA" : "Export IPA", systemImage: "lock") {
                    if isEncrypted {
                        Haptic.shared.play(.heavy)
                        do {
                            let result = try Decryption.decrypt(app)
//                            UIApplication.shared.alert(title: "Successfully decrypted",body: "You can find the IPA at \(result.path).")
                            share([result])
                            Haptic.shared.notify(.success)
                        } catch {
                            Haptic.shared.notify(.error)
                            UIApplication.shared.alert(body: error.localizedDescription)
                        }
                    } else {
                        UIApplication.shared.alert(body: "not implemented")
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu("", systemImage: "ellipsis.circle") {
                    
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        UIApplication.shared.confirmAlertDestructive(body: "Are you sure you want to delete \(app.name)?", onOK: {
                            do {
                                try app.uninstall()
                            } catch {
                                UIApplication.shared.alert(title: "An error occurred uninstalling \(app.name)", body: error.localizedDescription)
                            }
                        }, destructActionText: "Delete")
                    }
                }
            }
        }
        .tint(currentAccentColor)
        .navigationTitle(app.name)
        .task(priority: .background) {
            if let iconpath = app.pngIconPaths[safe: 0],
            let image = UIImage(contentsOfFile: app.bundleURL.path + "/" + iconpath) {
                withAnimation {
                    self.palette = Vibrant.from(image).getPalette()
                }
            }
        }
    }
    
//    func decryptIPA() throws {
//        if let proxy = app.rawProxy {
//            let dict: [String : Any] = [
//                "bundleID" : app.bundleIdentifier,
//                "name" : app.name,
//                "version" : app.version,
//                "executable" : URL(fileURLWithPath: app.rawProxy!.canonicalExecutablePath)
//            ]
//            
//            decryptApp(dict)
//        } else {
//            throw "Error getting ApplicationProxy for app \(app.bundleIdentifier)"
//        }
//    }
}
