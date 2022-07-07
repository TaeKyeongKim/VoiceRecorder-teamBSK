//
//  RecordFileManager.swift
//  VoiceRecorder
//
//  Created by Bran on 2022/07/01.
//

import AVFoundation
import UIKit

class RecordFileManager {

  static let shared = RecordFileManager()
  private let fileManager = FileManager.default
  private var documentDirectory: URL? = nil

  private init() {
    setup()
  }

  private func setup() {
    guard
      let documentDirectory = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
      ).first
    else {
      print("FileManager init Directory Error")
      return
    }
    self.documentDirectory = documentDirectory.appendingPathComponent("Record")
    print(documentDirectory)
  }

  private func createDirectory() {
    guard let documentDirectory = documentDirectory else { return }
    if fileManager.fileExists(atPath: documentDirectory.path) == false {
      do {
        try fileManager.createDirectory(
          atPath: documentDirectory.path,
          withIntermediateDirectories: true,
          attributes: nil
        )
      } catch {
        print("Create Record Directory Error")
      }
    }
  }

  func saveRecordFile(recordName: String, file: URL) {
    guard let documentDirectory = documentDirectory else { return }
    createDirectory()
    let recordURL = documentDirectory.appendingPathComponent(recordName)
    do {
      let data = try Data(contentsOf: file)
      try data.write(to: recordURL)
    } catch {
      print("Save Data Error")
    }
  }

  func loadRecordFile(_ recordName: String) -> AVAudioFile? {
    guard let documentDirectory = documentDirectory else { return nil }
    createDirectory()
    let recordURL = documentDirectory.appendingPathComponent(recordName)
    do {
      let recordfile = try AVAudioFile(forReading: recordURL)
      return recordfile
    } catch {
      print("Loading Data from FileManager fail")
      return nil
    }
  }

  func deleteRecordFile(_ recordName: String) {
    guard let documentDirectory = documentDirectory else { return }
    createDirectory()
    let recordURL = documentDirectory.appendingPathComponent(recordName)
    if fileManager.fileExists(atPath: recordURL.path) {
      do {
        try fileManager.removeItem(at: recordURL)
        print("Delete Success")
      }
      catch {
        print("Delete Fail")
      }
    }
  }
}
