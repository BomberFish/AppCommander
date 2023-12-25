// bomberfish
// App.swift – AppCommander
// created on 2023-12-21

//import LaunchServicesBridge
import Foundation
import OSLog

public let systemApplicationsUrl = URL(fileURLWithPath: "/Applications", isDirectory: true)
public let userApplicationsUrl = URL(fileURLWithPath: "/var/containers/Bundle/Application", isDirectory: true)

struct Application {
    var bundleIdentifier: String
    var name: String
    var bundleURL: URL
    var containerURL: URL
    var version: String
    
    var pngIconPaths: [String]
    var hiddenFromSpringboard: Bool
    
    var rawProxy: LSApplicationProxy?
    
    @discardableResult
    func open() -> Bool {
        return LSApplicationWorkspace.default().openApplication(withBundleID: bundleIdentifier)
    }

    func uninstall() throws {
        let err: NSErrorPointer = nil
        LSApplicationWorkspace.default().uninstallApplication(bundleIdentifier, withOptions: nil, error: err, usingBlock: nil)
        if let error = err?.pointee {
            throw error
        }
    }
}

enum AppManager {
    static func getApps() throws -> [Application] {
        var apps: [Application] = []
//        if isTrollStore {
        print("Using TrollStore to get apps")
        LSApplicationWorkspace.default().allApplications().forEach { app in
            var version: String?
            if let infoPlist = NSDictionary(contentsOf: app.bundleURL().appendingPathComponent("Info.plist")) as? [String: AnyObject] {
                version = infoPlist["CFBundleShortVersionString"] as? String
            }
            apps.append(
                Application(bundleIdentifier: app.applicationIdentifier, name: app.localizedName(), bundleURL: app.bundleURL(), containerURL: app.containerURL(), version: version ?? "Unknown", pngIconPaths: getPNGIcons(app.bundleURL(), app.applicationIdentifier), hiddenFromSpringboard: app.isRestricted, rawProxy: app)
            )
        }
//        } else {
//            print("Using MDC to get apps")
//            // MARK: - mdc time
//            let fm = FileManager.default
//            var dotAppDirs: [URL] = []
//
//            let systemAppsDir = try fm.contentsOfDirectory(at: systemApplicationsUrl, includingPropertiesForKeys: nil)
//            let userAppsDir = try fm.contentsOfDirectory(at: userApplicationsUrl, includingPropertiesForKeys: nil)
//
//            for userAppFolder in userAppsDir {
//                let userAppFolderContents = try fm.contentsOfDirectory(at: userAppFolder, includingPropertiesForKeys: nil)
//                if let dotApp = userAppFolderContents.first(where: { $0.absoluteString.hasSuffix(".app/") }) {
//                    dotAppDirs.append(dotApp)
//                }
//            }
//
//            dotAppDirs += systemAppsDir
//            for bundleUrl in dotAppDirs {
//                let infoPlistUrl = bundleUrl.appendingPathComponent("Info.plist")
//                if !fm.fileExists(atPath: infoPlistUrl.path) {
//                    // some system apps don't have it, just ignore it and move on.
//                    continue
//                }
//
//                guard let infoPlist = NSDictionary(contentsOf: infoPlistUrl) as? [String: AnyObject] else { UIApplication.shared.alert(body: "Error opening info.plist for \(bundleUrl.absoluteString)"); throw "Error opening info.plist for \(bundleUrl.absoluteString)" }
//                guard let CFBundleIdentifier = infoPlist["CFBundleIdentifier"] as? String else { UIApplication.shared.alert(body: "App \(bundleUrl.absoluteString) doesn't have bundleid"); throw ("App \(bundleUrl.absoluteString) doesn't have bundleid") }
//
//                var app = Application(bundleIdentifier: CFBundleIdentifier, name: "Unknown", bundleURL: bundleUrl, containerURL: .init(string: "")!, version: "Unknown", pngIconPaths: [], hiddenFromSpringboard: false)
//
//                if infoPlist.keys.contains("CFBundleShortVersionString") {
//                    guard let CFBundleShortVersionString = infoPlist["CFBundleShortVersionString"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(bundleUrl.absoluteString)"); throw ("Error reading display name for \(bundleUrl.absoluteString)") }
//                    app.version = CFBundleShortVersionString
//                } else if infoPlist.keys.contains("CFBundleVersion") {
//                    guard let CFBundleVersion = infoPlist["CFBundleVersion"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(bundleUrl.absoluteString)"); throw ("Error reading display name for \(bundleUrl.absoluteString)") }
//                    app.version = CFBundleVersion
//                }
//
//                if infoPlist.keys.contains("CFBundleDisplayName") {
//                    guard let CFBundleDisplayName = infoPlist["CFBundleDisplayName"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(bundleUrl.absoluteString)"); throw ("Error reading display name for \(bundleUrl.absoluteString)") }
//                    if CFBundleDisplayName != "" {
//                        app.name = CFBundleDisplayName
//                    } else {
//                        app.name = ((NSURL(fileURLWithPath: bundleUrl.path).deletingPathExtension)?.lastPathComponent)!
//                    }
//                } else if infoPlist.keys.contains("CFBundleName") {
//                    guard let CFBundleName = infoPlist["CFBundleName"] as? String else { UIApplication.shared.alert(body: "Error reading name for \(bundleUrl.absoluteString)"); throw ("Error reading name for \(bundleUrl.absoluteString)") }
//                    app.name = CFBundleName
//                }
//
//                app.pngIconPaths = getPNGIcons(app.bundleURL, app.bundleIdentifier)
//
//                app.containerURL = try getContainerURLManually(app.bundleIdentifier)
//
//                apps.append(app)
//            }
//        }
        return apps
    }
    
    private static func getContainerURLManually(_ bundleID: String) throws -> URL {
        // this is pretty fun.
        let fm: FileManager = .default
        var containerURL: URL?
        try? fm.contentsOfDirectory(atPath: "/var/containers/Bundle/Application/").forEach { dir in
            let metadataPlist = "/var/containers/Bundle/Application/" + dir + ".com.apple.mobile_container_manager.metadata.plist"
            if fm.fileExists(atPath: metadataPlist) {
                if let metadata = NSDictionary(contentsOfFile: metadataPlist) as? [String: AnyObject] {
                    if let mcmmetadata = metadata["MCMMetadataIdentifier"] as? String {
                        if mcmmetadata == bundleID {
                            containerURL = .init(fileURLWithPath: "/var/containers/Bundle/Application/" + dir + "/")
                        }
                    }
                }
            } else {
                throw "App does not have a container!"
            }
        }
        
        if let containerURL {
            return containerURL
        } else {
            throw "App does not have a container!"
        }
    }
    
    static func getPNGIcons(_ bundleURL: URL, _ bundleID: String) -> [String] {
        let infoPlistUrl = bundleURL.appendingPathComponent("Info.plist")
        if !FileManager.default.fileExists(atPath: infoPlistUrl.path) {
            return []
        }
                        
        guard let infoPlist = NSDictionary(contentsOf: infoPlistUrl) as? [String: AnyObject] else { return [] }
        
        var pngIconPaths = [String]()
        // obtaining png icons inside bundle. defined in info.plist
        if bundleID == "com.apple.mobiletimer" {
            // use correct paths for clock, because it has arrows
            // This looks absolutely horrible, why do we even try
            pngIconPaths += ["circle_borderless@2x~iphone.png"]
        }
        if let CFBundleIcons = infoPlist["CFBundleIcons"] {
            if let CFBundlePrimaryIcon = CFBundleIcons["CFBundlePrimaryIcon"] as? [String: AnyObject] {
                if let CFBundleIconFiles = CFBundlePrimaryIcon["CFBundleIconFiles"] as? [String] {
                    pngIconPaths += CFBundleIconFiles.map { $0 + "@2x.png" }
                }
            }
        }
        if infoPlist.keys.contains("CFBundleIconFile") {
            // happens in the case of pseudo-installed apps
            if let CFBundleIconFile = infoPlist["CFBundleIconFile"] as? String {
                pngIconPaths.append(CFBundleIconFile + ".png")
            }
        }
        if infoPlist.keys.contains("CFBundleIconFiles") {
            // only seen this happen in the case of Wallet
            if let CFBundleIconFiles = infoPlist["CFBundleIconFiles"] as? [String], !CFBundleIconFiles.isEmpty {
                pngIconPaths += CFBundleIconFiles.map { $0 + ".png" }
            }
        }
        return pngIconPaths
    }
}
