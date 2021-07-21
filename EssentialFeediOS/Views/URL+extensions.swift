//
//  URL+extensions.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/20/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import UIKit

extension URL {
    
    func convertToUIIMage() throws -> UIImage? {
        var image: UIImage?
        let data = try Data.init(contentsOf: self)
        image = UIImage(data: data)
        return image
    }
    
}
