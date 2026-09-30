//
//  String+Helper.swift
//  Imago
//
//  Created by Christopher Combes on 9/30/26.
//

import Foundation

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        guard let self else { return true }
        return self.isEmpty
    }
}
