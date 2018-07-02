//
//  WayPoint.swift
//  prototype_2
//
//  Created by Leo Schoberwalter on 27.06.18.
//  Copyright © 2018 Leo Schoberwalter. All rights reserved.
//


import Foundation
import SceneKit

class WayPoint: SCNNode {
    
    init(from file: String) {
        super.init()
        
        let nodesInFile = allNodes(from: file)
        nodesInFile.forEach { (node) in
            self.addChildNode(node)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func allNodes(from file: String) -> [SCNNode] {
        var nodesInFile = [SCNNode]()
        
        do {
            guard let sceneURL = Bundle.main.url(forResource: file, withExtension: nil) else {
                print("Could not find scene file \(file)")
                return nodesInFile
            }
            
            let objScene = try SCNScene(url: sceneURL as URL, options: [SCNSceneSource.LoadingOption.animationImportPolicy:SCNSceneSource.AnimationImportPolicy.doNotPlay])
            
            for childNode in objScene.rootNode.childNodes {
                nodesInFile.append(childNode)
            }
        } catch {
            
        }
        
        return nodesInFile
    }
    
}

