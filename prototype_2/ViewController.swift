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
import FontAwesome

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    lazy var sceneView: ARSCNView = {
        let view = ARSCNView(frame: CGRect.zero)
        view.delegate = self
        return view
    }()
    
    var startingPositionNode: SCNNode?
    var endingPostionNode: SCNNode?
    let cameraPosition = SCNVector3(0, 0, -0.5)
    
    var shouldPlaySound: Bool = false
    var sceneController = HoverScene()
    var didInitializeScene: Bool = false
    var waypoints: [WayPoint] = []
    var arrowNode: ArrowNode?
    var smallerPointOfView: SCNNode?
    var selectedWaypoint: WayPoint?
    var navigationMode: Bool = false
    var spotLight: SCNNode = SCNNode()
    var showMenu: Bool = true
    
    lazy var toggleMenuBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: view.frame.width-180, y:40 , width: 190, height: 60))
        btn.backgroundColor = UIColor.init(named: "mDarkTransp")
        btn.addTarget(self, action: #selector(toggleMenu), for: .touchUpInside)
        btn.layer.cornerRadius = 10.0
        btn.contentHorizontalAlignment = .left
        btn.clipsToBounds = true
        btn.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)
        btn.setTitle("   \(String.fontAwesomeIcon(name: .bars))  Hide Menu", for: .normal)
        btn.setTitle("   \(String.fontAwesomeIcon(name: .bars))", for: .selected)
        return btn
    }()
    
    lazy var trackingInfoLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: view.frame.width-280, y:(view.frame.height/2)-120 , width: 290, height: 60))
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title2)
        label.textAlignment = .left
        label.layer.cornerRadius = 10.0
        label.clipsToBounds = true
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.init(named: "mDarkTransp")
        return label
    }()
    
    lazy var routeInfoLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: view.frame.width-280, y:(view.frame.height/2)-55 , width: 290, height: 60))
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title2)
        label.textAlignment = .left
        label.layer.cornerRadius = 10.0
        label.clipsToBounds = true
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.init(named: "mDarkTransp")
        return label
    }()
    
    lazy var deleteRouteBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: view.frame.width-280, y:(view.frame.height/2)+10 , width: 290, height: 60))
        btn.backgroundColor = UIColor.init(named: "mDarkTransp")
        btn.addTarget(self, action: #selector(clearWaypoints), for: .touchUpInside)
        btn.layer.cornerRadius = 10.0
        btn.contentHorizontalAlignment = .left
        btn.clipsToBounds = true
        btn.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)
        btn.setTitle("   \(String.fontAwesomeIcon(name: .trash))  Delete Route", for: .normal)
        return btn
    }()
    
    lazy var startRouteBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: view.frame.width-280, y:(view.frame.height/2)+75, width: 290, height: 60))
        btn.backgroundColor = UIColor.init(named: "mDarkTransp")
        btn.addTarget(self, action: #selector(toggleNavigationMode), for: .touchUpInside)
        btn.layer.cornerRadius = 10.0
        btn.clipsToBounds = true
        btn.contentHorizontalAlignment = .left
        btn.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)
        btn.setTitle("   \(String.fontAwesomeIcon(name: .play))  Start Navigation", for: .normal)
        btn.setTitle("   \(String.fontAwesomeIcon(name: .edit))  Edit Route", for: .selected)

        return btn
    }()
    
    lazy var waypointInfoBox: UIView = {
        let view = UIView(frame: CGRect(x: self.view.frame.width-280, y:(self.view.frame.height/2)+180, width: 290, height: 120))
        view.layer.cornerRadius = 10.0
        view.clipsToBounds = true
        view.isHidden = true
        view.backgroundColor = UIColor.init(named: "mDarkTransp")
        return view
    }()
    
    lazy var waypointInfoLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y:0, width: 290, height: 60))
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title2)
        label.textAlignment = .left
        label.layer.cornerRadius = 10.0
        label.clipsToBounds = true
        label.textColor = UIColor.white
        return label
    }()
    
    lazy var deleteWaypointBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 60 , width: 290, height: 60))
        btn.addTarget(self, action: #selector(deleteSelectedWaypoint), for: .touchUpInside)
        btn.layer.cornerRadius = 10.0
        btn.clipsToBounds = true
        btn.isHidden = false
        btn.contentHorizontalAlignment = .left
        btn.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)
        btn.setTitle("   \(String.fontAwesomeIcon(name: .trash))  Delete Waypoint", for: .normal)
        return btn
    }()
    
    lazy var toggleSoundBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: view.frame.width-280, y: (view.frame.height/2)+75, width: 290, height: 60))
        btn.backgroundColor = UIColor.init(named: "mDarkTransp")
        btn.addTarget(self, action: #selector(toggleSound), for: .touchUpInside)
        btn.layer.cornerRadius = 10.0
        btn.clipsToBounds = true
        btn.isHidden = true
        btn.contentHorizontalAlignment = .left
        btn.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)
        btn.setTitle("   \(String.fontAwesomeIcon(name: .volumeOff))  Sound Off", for: .normal)
        btn.setTitle("   \(String.fontAwesomeIcon(name: .volumeUp))  Sound On", for: .selected)
        return btn
    }()
    
    lazy var addWaypointBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: (self.view.frame.size.width-80)/2, y: self.view.frame.size.height-130, width: 80, height: 80))
        btn.backgroundColor = UIColor.init(named: "mGreen")
        btn.addTarget(self, action: #selector(addWaypoint), for: .touchUpInside)
        btn.layer.cornerRadius = 40.0
        btn.contentHorizontalAlignment = .center
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.clipsToBounds = true
        btn.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
        btn.setTitle(String.fontAwesomeIcon(name: .plus), for: .normal)
        
        return btn
    }()
    
    lazy var navigationInfoLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: (self.view.frame.size.width-300)/2, y: self.view.frame.size.height-130, width: 300, height: 45))
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.textAlignment = .center
        label.layer.cornerRadius = 10.0
        label.clipsToBounds = true
        label.isHidden = true
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.init(named: "mDarkTransp")
        return label
    }()
    


    func getLightSpot() -> SCNNode {
        let light = SCNLight()
        light.type = .directional
        light.intensity = 2000
        light.temperature = 3000
        
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0,1,0)
        
        return lightNode
    }
    
    @objc func addArrow() {
        if(arrowNode == nil && waypoints.count >= 1){
            let arrow = ArrowNode()
            Helper.addChildNode(arrow, toNode: sceneView.scene.rootNode, inView: sceneView, cameraRelativePosition: cameraPosition)
            arrowNode = arrow
        }
    }
    
    @objc func removeArrow() {
        if(arrowNode != nil){
            arrowNode?.removeFromParentNode()
            arrowNode = nil
        }
    }
    
    
    @objc func clearWaypoints(sender: UIButton!) {
        if(waypoints.count >= 1){
            for waypoint in waypoints {
                waypoint.node.removeFromParentNode()
            }
            waypoints.removeAll()
            arrowNode?.destroy()
            arrowNode = nil
            unselectWaypoint(waypoint: selectedWaypoint)
        }
        setRouteInfoText()
    }
    
    
    @objc func toggleMenu(sender: UIButton!) {
        showMenu = !showMenu
        if(showMenu){
            for v in view.subviews {
                print(v)
                if(v.frame.width == 290){
                    v.frame.origin.x = view.frame.width - 280
                }
            }
        }else{
            for v in view.subviews {
                print(v)
                if(v.frame.width == 290){
                    v.frame.origin.x = view.frame.width
                }
            }
        }
    }
    
    @objc func toggleSound(sender: UIButton!) {
        shouldPlaySound = !shouldPlaySound
        if(shouldPlaySound){
            toggleSoundBtn.isSelected = true
        }else{
            toggleSoundBtn.isSelected = false
        }
    }
    
    @objc func addWaypoint(sender: UIButton) {
        if let currentFrame = sceneView.session.currentFrame {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = cameraPosition.z
            let transform = simd_mul(
                currentFrame.camera.transform,
                translation
            )
            
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
    
    @objc func deleteSelectedWaypoint(sender: UIButton) {
        if((selectedWaypoint) != nil){
            for (i, waypoint) in waypoints.enumerated() {
                if(selectedWaypoint == nil){
                    waypoint.number -= 1
                }
                if(waypoint.isSelected){
                    waypoints.remove(at: i)
                    waypoint.node.removeFromParentNode()
                    selectedWaypoint = nil
                    waypointInfoBox.isHidden = true
                }
            }
            setRouteInfoText()
        }
    }
    
    @objc func toggleNavigationMode(sender: UIButton!) {
        navigationMode = !navigationMode
        if(navigationMode){
            for wp in waypoints {
                wp.setOpen()
                wp.hide()
                unselectWaypoint(waypoint: wp)
            }
        
            addWaypointBtn.isEnabled = false
            addWaypointBtn.isHidden = true
            startRouteBtn.isSelected = true
            startRouteBtn.frame.origin = CGPoint(x: startRouteBtn.frame.origin.x, y: startRouteBtn.frame.origin.y-(startRouteBtn.frame.height+5))
            navigationInfoLabel.isHidden = false
            toggleSoundBtn.isEnabled = true
            toggleSoundBtn.isHidden = false
            deleteRouteBtn.isHidden = true
            waypointInfoBox.isHidden = true
            addArrow()
            getOpenWaypoints().last?.show()
            setRouteInfoText()
        }else{
            for wp in waypoints {
                wp.setOpen()
                unselectWaypoint(waypoint: wp)
            }
            toggleSoundBtn.isEnabled = false
            addWaypointBtn.isEnabled = true
            startRouteBtn.isSelected = false
            navigationInfoLabel.isHidden = true
            startRouteBtn.frame.origin = CGPoint(x: startRouteBtn.frame.origin.x, y: startRouteBtn.frame.origin.y+(startRouteBtn.frame.height+5))
            addWaypointBtn.isHidden = false
            toggleSoundBtn.isHidden = true
            deleteRouteBtn.isHidden = false
            waypointInfoBox.isHidden = true
            shouldPlaySound = false
            removeArrow()
            setRouteInfoText()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let camera = sceneView.session.currentFrame?.camera {
            didInitializeScene = true
            let transform = camera.transform
            let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            var waypointInfoLabelText = "No waypoints found";
            spotLight.light?.intensity = (sceneView.session.currentFrame?.lightEstimate?.ambientIntensity)!
            
            if(navigationMode){
                let openWaypoints = getOpenWaypoints()
                if(openWaypoints.count >= 1 && arrowNode != nil){
                    openWaypoints.last?.show()
                    arrowNode?.position = SCNVector3(position.x,position.y, (position.z-0.5))
                    arrowNode?.transformPosition(node: arrowNode!, inView: sceneView, cameraRelativePosition: cameraPosition)
                    arrowNode?.pointAt(position: (openWaypoints.last?.node.position)!)
                    
                    let distanceToNext = distanceBetweenPoints(A: (arrowNode?.position)!, B: (openWaypoints.last?.node.position)!)
                    waypointInfoLabelText = "Next Waypoint in \(String(format: "%.2f", distanceToNext)) m"
                    
                    if(shouldPlaySound){
                        if(isInRightDirection(toPoint: openWaypoints.last!.node)){
                            AudioServicesPlaySystemSound(1103);
                        }else{
                            AudioServicesPlaySystemSound(1155);
                        }
                    }
                
                    if(distanceToNext < 0.2) {
                        setRouteInfoText(plus: distanceToNext)
                        openWaypoints.last?.reached()
                    }
                    
                }else{
                    removeArrow()
                    if(waypoints.count >= 0){
                        waypointInfoLabelText = "Destination reached!"
                        setRouteInfoText()
                    }
                }
                
                DispatchQueue.main.async {
                    self.navigationInfoLabel.text = waypointInfoLabelText
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let wp = WayPoint(nr: waypoints.count+1, node: node)
        wp.arAnchor = anchor
        waypoints.append(wp)
        setRouteInfoText()
        
        
    }
    
    func setRouteInfoText(plus: CGFloat? = 0){
        DispatchQueue.main.async {
            if(self.navigationMode){
                self.routeInfoLabel.text = "   Distance left:  \(String(format: "%.2f", (self.getRouteDistanceFromWaypoints(waypoints: self.getOpenWaypoints())+plus!))) m"
            }else{
                self.routeInfoLabel.text = "   Route distance:  \(String(format: "%.2f", self.getRouteDistanceFromWaypoints(waypoints: self.waypoints))) m"
            }
        }
    }
    
    func getRouteDistanceFromWaypoints(waypoints: [WayPoint]) -> CGFloat{
        var routeDistance: CGFloat = 0.0
        for (i, wp) in waypoints.enumerated() {
            print(i)
            if(i+1 < waypoints.count){
                routeDistance += wp.getDistanceTo(position: waypoints[i+1].node.position)
            }
        }
        return routeDistance
    }
    
    func getOpenWaypoints() -> [WayPoint] {
        var openWaypoints: [WayPoint] = []
        for wp in waypoints {
            if(wp.isOpen){
                openWaypoints.append(wp)
            }
        }
        return openWaypoints
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
                isMaybeVisible = sceneView.isNode((waypoints.last?.node)!, insideFrustumOf: smallerPointOfView!)
            }
        }
        return isMaybeVisible
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Helper.lockPortrait(.portrait, andRotateTo: .portrait)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")

        view.addSubview(sceneView)
        view.addSubview(trackingInfoLabel)
        view.addSubview(navigationInfoLabel)
        view.addSubview(deleteRouteBtn)
        view.addSubview(addWaypointBtn)
        view.addSubview(toggleSoundBtn)
        view.addSubview(startRouteBtn)
        view.addSubview(routeInfoLabel)
        view.addSubview(toggleMenuBtn)
        waypointInfoBox.addSubview(deleteWaypointBtn)
        waypointInfoBox.addSubview(waypointInfoLabel)
        view.addSubview(waypointInfoBox)
        setRouteInfoText()
        
        spotLight.light = SCNLight()
        spotLight.scale = SCNVector3(1,1,1)
        spotLight.light?.intensity = 600
        spotLight.castsShadow = true
        spotLight.position = SCNVector3(0,0,2)
        spotLight.light?.type = SCNLight.LightType.directional
        spotLight.light?.color = UIColor.white
        sceneView.pointOfView?.addChildNode(spotLight)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true;
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func selectWaypoint(waypoint: WayPoint) {
        selectedWaypoint?.unSelect()
        waypoint.select()
        selectedWaypoint = waypoint
        waypointInfoBox.isHidden = false
        waypointInfoLabel.text = "   Waypoint: \(selectedWaypoint?.number)"
    }
    
    func unselectWaypoint(waypoint: WayPoint?) {
        selectedWaypoint?.unSelect()
        selectedWaypoint = nil
        waypointInfoBox.isHidden = true
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let hitLocationInView: CGPoint = sender.location(in: sceneView)
        let hits = self.sceneView.hitTest(hitLocationInView, options: nil)
        
        if(!navigationMode){
            if let node = hits.first?.node {
                selectWaypoint(waypoint: getWaypointFromNode(node: node)!)
            }else{
                unselectWaypoint(waypoint: selectedWaypoint)
            }
        }
    }
    
    func getWaypointFromNode(node: SCNNode) -> WayPoint? {
        for wp in waypoints {
            if(node == wp.node){
                return wp
            }
        }
        return waypoints.last
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        var status = "   Tracking State: Loading..."
        switch camera.trackingState {
        case ARCamera.TrackingState.notAvailable:
            status = "   Tracking State: Not available"
        case ARCamera.TrackingState.limited(_):
            status = "   Tracking State:  Analyzing..."
        case ARCamera.TrackingState.normal:
            status = "   Tracking State: Ready"
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
    
    static func addChildNode(_ node: SCNNode, toNode: SCNNode, inView: ARSCNView, cameraRelativePosition: SCNVector3) {
        guard let currentFrame = inView.session.currentFrame else { return }
        let camera = currentFrame.camera
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = cameraRelativePosition.x
        translationMatrix.columns.3.y = cameraRelativePosition.y
        translationMatrix.columns.3.z = cameraRelativePosition.z
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        node.simdTransform = modifiedMatrix
        toNode.addChildNode(node)
    }
}
