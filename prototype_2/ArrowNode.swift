//
//  ArrowNode.swift
//  prototype_2
//
//  Created by Leo Schoberwalter on 28.06.18.
//  Copyright © 2018 Leo Schoberwalter. All rights reserved.
//

import Foundation
import SceneKit

class SceneObject: SCNNode {
    
    init(from file: String) {
        super.init()
        
        let arrowScene = SCNScene(named: file)
        for arrowNode in (arrowScene?.rootNode.childNodes)!{
            self.addChildNode(arrowNode)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ArrowNode: SceneObject {
    
    init() {
        super.init(from: "art.scnassets/arrow.scn")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pointAt(position: SCNVector3) {
        
        removeAllActions()
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.10
        look(at: position)
        SCNTransaction.commit()
        
    }
}
