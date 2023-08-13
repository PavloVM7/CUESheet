//
//  File.swift
//  
//
//  Created by Pavlo Moisieienko on 11.08.2023.
//

import Foundation

public enum CUEFileType {
    case UNKNOWN, WAVE, MP3
    static func fromString(_ name: String) -> CUEFileType {
        switch name.uppercased() {
        case "WAVE":
            return .WAVE
        case "MP3":
            return .MP3
        default:
            return .UNKNOWN
        }
    }
}
