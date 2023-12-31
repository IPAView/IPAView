//
//  Utils.swift
//  IPAView
//
//  Created by everettjf on 2023/12/30.
//

import Foundation

import AppKit

enum UtilsError: Error {
    case error(String)
}


class Utils {
    static func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB] // Specify the units you want to use
        formatter.countStyle = .file
        formatter.includesUnit = true // Include the unit in the output string
        formatter.isAdaptive = true // Use adaptive units (e.g., using MB instead of KB when appropriate)
        
        return formatter.string(fromByteCount: Int64(bytes))
    }
    static func isURLDirectory(url: URL) -> Bool {
        let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey])
        return resourceValues?.isDirectory ?? false
    }
    
    static func directoryExists(at url: URL) -> Bool {
        let path = url.path(percentEncoded: false)
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        return exists && isDir.boolValue
    }
    
    static func fileExists(at url: URL) -> Bool {
        let path = url.path(percentEncoded: false)
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        return exists && !isDir.boolValue
    }
    

    static func findFirstAppDirectory(at path: URL) -> URL? {
        let fileManager = FileManager.default
        do {
            let items = try fileManager.contentsOfDirectory(atPath: path.path(percentEncoded: false))

            for item in items {
                let fullPath = path.appending(path: item)
                var isDir: ObjCBool = false

                if fileManager.fileExists(atPath: fullPath.path(percentEncoded: false), isDirectory: &isDir),
                   isDir.boolValue,
                   item.hasSuffix(".app") {
                    return fullPath
                }
            }
        } catch {
            print("Error reading contents of directory: \(error)")
        }
        return nil
    }

    static func isMachOFile(atPath path: URL) -> Bool {
        do {
            let fileData = try Data(contentsOf: path, options: .mappedIfSafe)
            if fileData.count >= 4 {
                let magicNumber = fileData.withUnsafeBytes { $0.load(as: UInt32.self) }
                let knownMachOMagicNumbers: [UInt32] = [0xFEEDFACE, 0xFEEDFACF, 0xCAFEBABE, 0xBEBAFECA, 0xFEEDFACD, 0xCEFAEDFE]
                return knownMachOMagicNumbers.contains(magicNumber)
            }
        } catch {
            print("Error reading file: \(error)")
        }

        return false
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func getCacheDirectory() -> URL {
        let dir = Utils.getDocumentsDirectory().appending(path: "CacheDirectory")
        return dir
    }
    
    
    static func revealInFinder(fileURL: URL) {
        NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: "")
    }
    
    
    static func openURL(_ url: String) {
        if let realUrl = URL(string: url) {
            NSWorkspace.shared.open(realUrl)
        }
    }
    
    static func openFile(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
    
    static func copyToPasteboard(string: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()  // Clear existing pasteboard contents
        pasteboard.setString(string, forType: .string)
    }

    static func searchWithDefaultBrowser(query: String, searchEngine: String = "google") {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        var urlString = ""
        
        switch searchEngine.lowercased() {
        case "google":
            urlString = "https://www.google.com/search?q=\(encodedQuery)"
        case "bing":
            urlString = "https://www.bing.com/search?q=\(encodedQuery)"
        case "baidu":
            urlString = "https://www.baidu.com/s?wd=\(encodedQuery)"
        default:
            urlString = "https://www.google.com/search?q=\(encodedQuery)"
        }

        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
    
    static func getUserDownloadsDirectory() -> URL {
        let fileManager = FileManager.default
        let downloadsURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        return downloadsURL
    }
    
    static func listFilesInUserDownloadsDirectory(fileExtension: String) -> Result<[URL], UtilsError> {
        let fileManager = FileManager.default
        guard let downloadsURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            print("Downloads directory not found.")
            return .failure(.error("Failed to find Downloads directory"))
        }

        do {
            let fileURLs = try fileManager.contentsOfDirectory(atPath: downloadsURL.path)
            
            let results:[URL] = fileURLs.compactMap { fileName in
                let url = downloadsURL.appending(path: fileName)
                if url.pathExtension.lowercased() != fileExtension.lowercased() {
                    return nil
                }
                return url
            }
            return .success(results)
        } catch {
            print("Error while enumerating files \(downloadsURL.path): \(error.localizedDescription)")
            return .failure(.error("Failed to access Downloads directory : \(error.localizedDescription)"))
        }
    }

}
