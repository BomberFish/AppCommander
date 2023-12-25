// bomberfish
// Decryption.swift – AppCommander
// created on 2023-12-22

import Foundation

struct Decryption {
    static func isEncrypted(_ app: Application) -> Bool {
        // TODO: Get ChOma working
        return app.rawProxy?.isAppStoreVendable ?? false && app.rawProxy?.applicationType != "System"
//        if let proxy = app.rawProxy {
//            let cStringPointer = proxy.canonicalExecutablePath.withCString { pointer in
//                return UnsafeMutablePointer(mutating: pointer)
//            }
//            return macho_at_path_is_encrypted(cStringPointer)
//        } else {
//            return true
//        }
    }
    
    @discardableResult
    static func decrypt(_ app: Application) throws -> URL {
        if let proxy = app.rawProxy {
            let dict: [String : Any] = [
                "bundleID" : app.bundleIdentifier,
                "name" : app.name,
                "version" : app.version,
                "executable" : URL(fileURLWithPath: proxy.canonicalExecutablePath)
            ]
            let ret = try TDUtils().decryptApp(dict)
            if let ret {
                return .init(fileURLWithPath: ret)
            } else {
                throw "Decryption hit a *very* unexpected snag. Please report this to BomberFish."
            }
        } else {
            throw "Decryption hit an unexpected snag. Specifically, there was an error getting the raw LSApplicationProxy for app \(app.bundleIdentifier)"
        }
    }
}
