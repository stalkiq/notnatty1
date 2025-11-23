//
//  ContentModeration.swift
//  not natty
//
//  Simple keyword filter to block prohibited PED-related terms.
//

import Foundation

enum ContentModeration {
    // Keep list focused on clearly banned PED keywords; lowercase for matching
    static let bannedTerms: [String] = [
        "testosterone", "trenbolone", "deca", "nandrolone", "anavar",
        "winstrol", "dianabol", "primobolan", "masteron", "sarm",
        "sarms", "eq", "equipoise", "hgh", "peptide cycle", "pct",
        "tren", "test e", "test c", "test p"
    ]

    static func containsBannedTerms(_ text: String) -> Bool {
        let lowered = text.lowercased()
        return bannedTerms.contains { lowered.contains($0) }
    }
}







