//
//  UITableView+Extension.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/20/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(identifier: String? = nil) -> T {
        dequeueReusableCell(withIdentifier: identifier ?? String(describing: T.self)) as! T
    }
    
    func registerReusableCell<T: UITableViewCell>(cell: T.Type, identifier: String? = nil) {
        register(cell, forCellReuseIdentifier: identifier ?? String(describing: T.self))
    }
}
