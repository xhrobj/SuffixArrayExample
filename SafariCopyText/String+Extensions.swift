//
//  String+Extensions.swift
//  SafariCopyText
//
//

import Foundation

extension String {
    var wordSuffixList: [String] {
        let sequence = SuffixSequence(text: self)
        var iterator = sequence.makeIterator()

        var result = [String]()
        while let suffix = iterator.next() {
            result.append(suffix)
        }
        
        return result
    }
}
