//
//  ViewController.swift
//  prototype_2
//
//  Created by Leo Schoberwalter on 03.05.18.
//  Copyright © 2018 Leo Schoberwalter. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    lazy var sceneView: ARSCNView = {
        let view = ARSCNView(frame: CGRect.zero)
        view.delegate = self
        return view
    }()
    
    var startingPositionNode: SCNNode?
    var endingPostionNode: SCNNode?
    let cameraPosition = SCNVector3(0, 0, -0.3)
    let currentCameraPosition = SCNVector3(0, 0, -0.3)

    var sceneController = HoverScene()
    var didInitializeScene: Bool = false
    var waypoints: [WayPoint] = []
    var arrowNode: ArrowNode?
    var smallerPointOfView: SCNNode?
    
    lazy var trackingInfoLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 40, width: 300, height: 60))
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title2)
        label.textAlignment = .center
        label.backgroundColor = UIColor(white: 1, alpha: 0.7)
        return label
    }()
    
    lazy var waypointInfoLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 120, width: 300, height: 200))
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.textAlignment = .left
        label.backgroundColor = UIColor(white: 1, alpha: 0.7)
        return label
    }()
    
    lazy var nodeClearBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 20, y: 340, width: 300, height: 200))
        btn.backgroundColor = UIColor(white: 1, alpha: 0.7)
        btn.addTarget(self, action: #selector(clearNodes), for: .touchUpInside)

        return btn
    }()
    
    @objc func clearNodes(sender: UIButton!) {
      
        if(arrowNode == nil && waypoints.count >= 1){
            let arrow = ArrowNode()
            Helper.addChildNode(arrow, toNode: sceneView.scene.rootNode, inView: sceneView, cameraRelativePosition: cameraPosition)
            arrowNode = arrow
        }

    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let currentTransform = frame.camera.transform
        print(currentTransform)
    }
    
    func getPositionAndOrientationOf(_ node: SCNNode, relativeTo referenceNode: SCNNode) {
        let referenceNodeTransform = matrix_float4x4(referenceNode.transform)
        
        // Setup a translation matrix with the desired position
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = 0
        translationMatrix.columns.3.y = 0
        translationMatrix.columns.3.z = 0
        
        // Combine the configured translation matrix with the referenceNode's transform to get the desired position AND orientation
        let updatedTransform = matrix_multiply(referenceNodeTransform, translationMatrix)
        let transform = SCNMatrix4(updatedTransform)
        print(transform)
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let camera = sceneView.session.currentFrame?.camera {
            didInitializeScene = true
            let transform = camera.transform
            let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            var waypointInfoLabelText = "No waypoints found";
            
            if(waypoints.count >= 1){
                let distanceToNext = distanceBetweenPoints(A: position, B: (waypoints.last?.position)!)
                if(distanceToNext < 0.1) {
                    waypoints.last?.reached()
                    waypoints.popLast()
                }
                
                if(isInRightDirection(toPoint: waypoints.last!)){
                    AudioServicesPlaySystemSound(1103);
                }else{
                    AudioServicesPlaySystemSound(1155);
                }
                
                if(arrowNode != nil && waypoints.count >= 1){
                    arrowNode?.position = SCNVector3(position.x,position.y, (position.z-0.5))
                    Helper.transformArrowPosition(node: arrowNode!, inView: sceneView, cameraRelativePosition: cameraPosition)
                    arrowNode?.pointAt(position: (waypoints.last?.position)!)
                    waypointInfoLabelText = "Next Waypoint in \(String(format: "%.2f", distanceToNext)) m"
                }else if(arrowNode != nil){
                    arrowNode?.removeFromParentNode()
                    arrowNode = nil
                    waypointInfoLabelText = "Destination reached!"
                }
                
                DispatchQueue.main.async {
                    self.waypointInfoLabel.text = waypointInfoLabelText
                }
                
            }
            
        }
    }
    
    func isInRightDirection(toPoint: SCNNode) -> Bool {
        var isMaybeVisible = false
        if var pointOfView: SCNNode = sceneView.pointOfView {
            if(smallerPointOfView != nil){
                smallerPointOfView?.removeFromParentNode()
            }
            if let camera = sceneView.session.currentFrame?.camera {
                let transform = camera.transform
                let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
                smallerPointOfView = SCNNode()
                smallerPointOfView?.position = pointOfView.position
                smallerPointOfView?.rotation = pointOfView.rotation
                smallerPointOfView?.camera = pointOfView.camera
                smallerPointOfView?.position.z = Float((smallerPointOfView?.position.z)!) - Float(distanceBetweenPoints(A: toPoint.position, B: position)*0.5)
                Helper.addChildNode(smallerPointOfView!, toNode: sceneView.scene.rootNode, inView: sceneView, cameraRelativePosition: cameraPosition)
                
                isMaybeVisible = sceneView.isNode((waypoints.last)!, insideFrustumOf: smallerPointOfView!)
            }
        }
        return isMaybeVisible
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(sceneView)
        view.addSubview(trackingInfoLabel)
        view.addSubview(waypointInfoLabel)
        view.addSubview(nodeClearBtn)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.frame = view.bounds
        //infoLabel.frame = CGRect(x: 0, y: 16, width: view.bounds.width, height: 64)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true;
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        let wp = WayPoint()
        addLightNodeTo(wp)
        Helper.addChildNode(wp, toNode: sceneView.scene.rootNode, inView: sceneView, cameraRelativePosition: cameraPosition)
        waypoints.append(wp)
        
    }
    
    func addLightNodeTo(_ node: SCNNode) {
        let lightNodeTop = getLightNodeTop()
        let lightNodeBot = getLightNodeBot()
        node.addChildNode(lightNodeTop)
        node.addChildNode(lightNodeBot)
        //lightNodes.append(lightNode)
    }
    
    func getLightNodeTop() -> SCNNode {
        let light = SCNLight()
        light.type = .directional
        light.intensity = 2000
        light.temperature = 3000
        
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0,1,0)
        
        return lightNode
    }
    
    func getLightNodeBot() -> SCNNode {
        let light = SCNLight()
        light.type = .omni
        light.intensity = 500
        light.temperature = 3000
        
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0,-1,0)
        
        return lightNode
    }
    
    func randomSphere() -> SCNNode{
        let sphere = SCNNode(geometry: SCNSphere(radius: 0.01))
        sphere.geometry?.firstMaterial?.diffuse.contents = generateRandomColor()
        return sphere
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    func generateRandomColor() -> UIColor {
        let h : CGFloat = CGFloat(arc4random() % 256) / 256
        let s : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5
        let b : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5
    
        return UIColor(hue: h, saturation: s, brightness: b, alpha: 1)
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        var status = "Tracking State: Loading..."
        switch camera.trackingState {
        case ARCamera.TrackingState.notAvailable:
            status = "Tracking State: Not available"
        case ARCamera.TrackingState.limited(_):
            status = "Tracking State:  Analyzing..."
        case ARCamera.TrackingState.normal:
            status = "Tracking State: Ready"
        }
        trackingInfoLabel.text = status
    }
    
    func distanceBetweenPoints(A: SCNVector3, B: SCNVector3) -> CGFloat {
        let d = sqrt(
            (A.x - B.x) * (A.x - B.x)
            + (A.y - B.y) * (A.y - B.y)
            + (A.z - B.z) * (A.z - B.z)
        )
        return CGFloat(d)
    }
}
