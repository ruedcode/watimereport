//
//  StringExtension.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 29.01.2018.
//

import Foundation

extension String {
//    func capturedGroups(withRegex pattern: String) -> [String] {
//        var results = [String]()
//
//        var regex: NSRegularExpression
//        do {
//            regex = try NSRegularExpression(pattern: pattern, options: [])
//        } catch {
//            return results
//        }
//
//        let nsString = NSString(string: self)
//        let all = NSRange(location: 0, length: nsString.length)
//        regex.enumerateMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: all) {(result : NSTextCheckingResult?, _, _) in
//            let capturedRange = result!.range(at: 1)
//            if !NSEqualRanges(capturedRange, NSMakeRange(NSNotFound, 0)) {
//                let theResult = nsString.substring(with: result!.range(at: 1))
//                results.append(theResult)
//            }
//        }
//
//        return results
//    }
   
    func capturedGroups(withRegex pattern: String) -> [String] {
        var results = [String]()

        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return results
        }

        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))

        guard let match = matches.first else { return results }

        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }

        let nsString = NSString(string:self)
        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.range(at: i)
            let matchedString = nsString.substring(with: capturedGroupIndex)
            results.append(matchedString)
        }

        return results
    }

    func stringByReplacingFirstOccurrenceOfString(target: String, withString replaceString: String) -> String {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
}
