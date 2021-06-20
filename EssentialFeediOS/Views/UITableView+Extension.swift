//
//  UITableView+Extension.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/20/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
    
    func registerReusableCell<T: UITableViewCell>(cell: T.Type) {
        let identifer = String(describing: T.self)
        register(cell, forCellReuseIdentifier: identifer)
    }
}
