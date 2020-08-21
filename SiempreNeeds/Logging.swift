//
//  Logging.swift
//  SiempreNeeds
//


import Foundation

func Log(_ format: String, _ args: CVarArg...) {
    NSLog("[SiempreNeeds] "+format, args) // TODO Bugfender
}
