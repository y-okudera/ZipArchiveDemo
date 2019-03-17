//
//  ViewController.swift
//  ZipArchiveDemo
//
//  Created by YukiOkudera on 2019/03/17.
//  Copyright © 2019 Yuki Okudera. All rights reserved.
//

import UIKit
import ZipArchive

final class ViewController: UIViewController {

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        copyZipToDocumentsDir()
        unzipPressed()
    }
}

extension ViewController {
    
    /// Get path to save zip file.
    private func sampleZipFilePath() -> String? {
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let zipFileURL = documentsDir.appendingPathComponent("test.zip")
        let zipFilePath = zipFileURL.path
        print("zipFilePath", zipFilePath)
        return zipFilePath
    }
    
    /// Copy zip file from main bundle.
    private func copyZipToDocumentsDir() {
        guard let sourcePath = Bundle.main.path(forResource: "test", ofType: "zip") else {
            return
        }
        guard let destinationPath = sampleZipFilePath() else {
            return
        }
        do {
            try FileManager.default.copyItem(atPath: sourcePath, toPath: destinationPath)
        } catch {
            print("File copy error:\(error)")
        }
        print("Copy succeeded.")
    }
    
    /// Remove zip file.
    private func removeZip() {
        guard let zipPath = sampleZipFilePath() else {
            return
        }
        if !FileManager.default.fileExists(atPath: zipPath) {
            return
        }
        do {
            try FileManager.default.removeItem(atPath: zipPath)
        } catch {
            print("File remove error:\(error)")
        }
    }
}

extension ViewController {
    
    func unzipPressed() {
        
        // TODO: - Show indicator
        
        guard let zipPath = self.sampleZipFilePath() else {
            return
        }
        
        guard let unzipPath = tempUnzipPath() else {
            return
        }
        
        #if DEBUG
        let start = Date()
        #endif
        
        let success: Bool = SSZipArchive.unzipFile(
            atPath: zipPath,
            toDestination: unzipPath,
            preserveAttributes: true,
            overwrite: true,
            nestedZipLevel: 1,
            // password: password?.isEmpty == false ? password : nil,
            password: nil,
            error: nil,
            delegate: nil,
            progressHandler: nil,
            completionHandler: nil
        )
        
        if success != false {
            print("Success unzip")
            removeZip()
        } else {
            print("No success unzip")
            return
        }
        
        #if DEBUG
        let elapsed = Date().timeIntervalSince(start)
        print("zip processing time: \(elapsed)sec")
        #endif
        
        // TODO: - Hide indicator
    }
    
    /// Get path of unzip file.
    func tempUnzipPath() -> String? {
        guard let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        let url = cachesDir.appendingPathComponent("\(UUID().uuidString)")
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }
        return url.path
    }
}
