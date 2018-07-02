//
//  WayPoint.swift
//  prototype_2
//
//  Created by Leo Schoberwalter on 27.06.18.
//  Copyright © 2018 Leo Schoberwalter. All rights reserved.
//


import Foundation
import SceneKit
import AVFoundation

class WayPoint: SCNNode {
    
    override init() {
        super.init()
        self.geometry = SCNSphere(radius: 0.01)
        self.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        self.opacity = 1
    }
    
    func hide() {
        self.opacity = 0.05
    }
    
    func reached() {
        self.hide()
        AudioServicesPlaySystemSound(1103);
    }
    
}

