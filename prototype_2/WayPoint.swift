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
import ARKit

class WayPoint: NSObject {
    var isSelected: Bool = false
    var number: Int
    var isOpen: Bool = true
    var node: SCNNode!
    var arAnchor: ARAnchor?
    
    init(nr: Int, node: SCNNode) {
        self.node = node
        self.node.geometry = SCNSphere(radius: 0.04)
        self.node.geometry?.firstMaterial?.diffuse.contents = UIColor.init(named: "mGreen")
        self.node.geometry?.firstMaterial?.lightingModel = .physicallyBased
        self.node.geometry?.firstMaterial?.metalness.contents = 0.3
        self.node.geometry?.firstMaterial?.reflective.contents = 0.8
        self.node.geometry?.firstMaterial?.roughness.contents = 0.715
        self.number = nr
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        self.node.opacity = 1
    }
    
    func hide() {
        self.node.opacity = 0
    }
    
    func setOpen() {
        self.node.geometry?.firstMaterial?.diffuse.contents = UIColor.init(named: "mGreen")
        self.node.opacity = 1
        self.isOpen = true
    }
    
    func reached() {
        self.hide()
        self.isOpen = false
        AudioServicesPlaySystemSound(1103);
    }
    
    func select() {
        self.isSelected = true
        self.node.geometry?.firstMaterial?.diffuse.contents = UIColor.init(named: "mBlue")
    }
    
    func unSelect() {
        self.isSelected = false
        self.node.geometry?.firstMaterial?.diffuse.contents = UIColor.init(named: "mGreen")
    }
    
    func getDistanceTo(position: SCNVector3) -> CGFloat {
        let mPosition = self.node.position
        let d = sqrt(
            (mPosition.x - position.x) * (mPosition.x - position.x)
                + (mPosition.y - position.y) * (mPosition.y - position.y)
                + (mPosition.z - position.z) * (mPosition.z - position.z)
        )
        return CGFloat(d)
    }
    
    
}

