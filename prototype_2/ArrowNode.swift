//
//  ArrowNode.swift
//  prototype_2
//
//  Created by Leo Schoberwalter on 28.06.18.
//  Copyright © 2018 Leo Schoberwalter. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

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
    
    func destroy() {
        self.removeFromParentNode()
    }
    
    func transformPosition(node: SCNNode, inView: ARSCNView, cameraRelativePosition: SCNVector3) {
        guard let currentFrame = inView.session.currentFrame else { return }
        let camera = currentFrame.camera
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = (cameraRelativePosition.x + 0.06)
        translationMatrix.columns.3.y = (cameraRelativePosition.y)
        translationMatrix.columns.3.z = (cameraRelativePosition.z - 0.03)
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        node.simdTransform = modifiedMatrix
    }
    
}
