//
//  String+Extension.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/22/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
