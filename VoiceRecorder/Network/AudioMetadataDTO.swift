//
//  AudioMetaData.swift
//  VoiceRecorder
//
//  Created by Kai Kim on 2022/07/01.
//

import Foundation
import FirebaseStorage

extension StorageMetadata {
    func toDomain() -> AudioPresentation  {
        return AudioPresentation(filename: self.name,
                                   createdDate: self.timeCreated ?? Date(),
                                   length: self.customMetadata?[CustomMetadata.fullLength])
    }
}

