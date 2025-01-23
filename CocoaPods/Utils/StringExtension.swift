//
//  StringExtension.swift
//  CocoaPods
//
//  Created by Tardes on 23/01/2025.
//

import Foundation
import UIKit

extension String {
    func sizeWithFont(font: UIFont, forWidth width: CGFloat) -> CGSize {
        let fString = self as NSString
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        let attrDict = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        let maximumSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let rect = fString.boundingRect(with: maximumSize, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin],
            attributes: attrDict, context: nil)
        return rect.size
    }
}
