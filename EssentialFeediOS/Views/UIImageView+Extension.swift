//
//  UIImageView+Extension.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/20/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import UIKit

extension UIImageView {
    func animateImageShowing(_ newImage: UIImage?) {
        image = newImage
        guard  newImage != nil else { return }
        
        alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1.0
        }
    }
}
