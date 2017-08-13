//
//  Helpers.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/10/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit

extension Date {
    
    var  shortString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        return dateFormatter.string(from: self)
    }
    
}

extension NSDate {
    
    var  shortString: String {
        let date = self as Date
        return date.shortString
    }
    
}

extension String {
    
    var shortDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate,
                                   .withTime,
                                   .withDashSeparatorInDate,
                                   .withColonSeparatorInTime]
        let dateObj = formatter.date(from: self)
        return dateObj
    }
    
    var shortNSDate: NSDate? {
        return self.shortDate as NSDate?
    }
    
    var dateTimeInterval: TimeInterval? {
        return self.shortDate?.timeIntervalSince1970
    }
    
}

extension NSString {
    
    func getTokens() -> [String] {
        var tokens = [String]()
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames, .omitOther]
        let schemes = NSLinguisticTagger.availableTagSchemes(forLanguage: "en")
        let tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
        tagger.string = self as String
        tagger.enumerateTags(in: NSMakeRange(0, self.length), scheme: NSLinguisticTagSchemeNameTypeOrLexicalClass, options: options) { (tag, tokenRange, _, _) in
            let token = self.substring(with: tokenRange)
            if !["Preposition", "Particle", "Determiner", "Verb", "Adverb", "Pronoun"].contains(tag)  {
                if token != "|" {
                    tokens.append(token)
                }
            }
        }
        return tokens
    }
    
}

extension TimeInterval {
    
    var date: Date {
        return Date(timeIntervalSince1970: self)
    }
    
}

extension UIColor {

    static var appColor: UIColor {
        return UIColor(red: 48.0 / 255.0, green: 131.0/255.0, blue: 251/255.0, alpha: 1.0)
    }
    
}

