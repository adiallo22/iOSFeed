//
//  UIView+Helpers.swift
//  EssentialFeediOSTests
//
//  Created by Abdul Diallo on 8/30/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
