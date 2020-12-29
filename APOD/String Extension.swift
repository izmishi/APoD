//
//  String Extension.swift
//  APOD
//
//  Created by Izumu Mishima on 02/07/2020.
//

import Foundation

extension String {
    func substringFromNSRange(_ nsRange: NSRange) -> Substring {
        guard let range = Range(nsRange, in: self) else { return self[...]}
        return self[range]
    }
}
