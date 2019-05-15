//
//  BeachesTextView.swift
//  demo
//
//  Created by Johan Halin on 15/05/2019.
//  Copyright © 2019 Dekadence. All rights reserved.
//

import UIKit

class BeachesTextView: UIView {
    private var images = [UIView]()
    private var position = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        for i in 1...5 {
            let image = UIImage(named: "beachesleavetext\(i)")
            let imageView = UIImageView(image: image)
            imageView.frame = self.bounds
            imageView.isHidden = true
            addSubview(imageView)
            
            self.images.append(imageView)
        }
    }
    
    func showNextImage() {
        for view in self.images {
            view.isHidden = true
        }
        
        self.images[self.position].isHidden = false
        
        self.position += 1
        
        if self.position >= self.images.count {
            self.position = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
