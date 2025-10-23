//
//  JournalEntry.swift
//  JournalApp8
//
//  Created by Reema Alkhelaiwi on 23/10/2025.
//
import Foundation

struct JournalEntry: Identifiable {
    let id = UUID()
    var title: String
    var content: String
    var date: Date
    var isBookmarked: Bool = false
}
