//
//  set.swift
//  idiots
//
//  Created by Jason Foster on 14/02/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//
import Foundation

extension Set {
    public func randomObject() -> Element? {
        let n = Int(arc4random_uniform(UInt32(self.count)))
        let index = self.index(self.startIndex, offsetBy: n)
        return self.count > 0 ? self[index] : nil
    }
}
