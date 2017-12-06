//
//  ViewController.swift
//  MoveBlock
//
//  Created by Ryan Wittrup on 12/5/17.
//  Copyright © 2017 Ryan Wittrup. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    //MARK: - Long-lived Variables
    var blocks = [SCNNode] ()
    var selectedBlock: SCNNode?
    
    struct CollisionTypes : OptionSet {
        let rawValue: Int
        
        static let bottom  = CollisionTypes(rawValue: 1 << 0)
        static let shape = CollisionTypes(rawValue: 1 << 1)
    }
    
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        //
        sceneView.autoenablesDefaultLighting = true
        
        
        
        addBlockToScene(name: "block1", position: SCNVector3(x: 0, y: 0.1, z: -0.5)) // -z axis is AWAY from user
        addBlockToScene(name: "block2", position: SCNVector3(x: 0, y: -0.1, z: -0.5)) // -z axis is AWAY from user
        addBlockToScene(name: "block3", position: SCNVector3(x: 0.1, y: 0.1, z: -0.5)) // -z axis is AWAY from user
        
        
        
        // gesture recognizers to handle user inputs
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    
    // MARK: - ARSCNViewDelegate
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // try to downcast planeAnchor to ARPlaneAnchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)
    }
    
//    TODO - expand existing plane
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        <#code#>
//    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    //MARK: - Gesture Methods
    @objc func tap(sender: UITapGestureRecognizer) -> Void {
        print("tapped")
        
        let touchLocation = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(touchLocation)
        
        
        //TODO - delete - creates block at tap for testing purposes
        let hitTestResultsPlane = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if let hitTestResultPlane = hitTestResultsPlane.first {
            addBlockToScene(name: "tapToCreateBlock", position: SCNVector3Make(hitTestResultPlane.worldTransform.columns.3.x, hitTestResultPlane.worldTransform.columns.3.y + 0.50, hitTestResultPlane.worldTransform.columns.3.z))
        }
        //TODO - delete
        
        
        if let hitTestResult = hitTestResults.first {
            
            // only select objects with 'block' in their name
            // guard against accidentally activating featurePoints and planes
            guard let name = hitTestResult.node.name?.contains("block") else {
                return
            }
            
            print(name)
            print(hitTestResult.node.name!)
            
            setSelectedBlock(hitTestResultNode: hitTestResult.node)
            
            print(selectedBlock)
        }
        
    }
    
    
    //MARK: - Button Methods
    @IBAction func movePositiveX(_ sender: UIButton) {
        guard selectedBlock != nil else {
            return
        }
        translateX(node: selectedBlock!, distance: 0.05)
    }
    
    @IBAction func moveNegativeX(_ sender: UIButton) {
        guard selectedBlock != nil else {
            return
        }
        translateX(node: selectedBlock!, distance: -0.05)
    }
    
    @IBAction func movePositiveY(_ sender: UIButton) {
        guard selectedBlock != nil else {
            return
        }
        translateY(node: selectedBlock!, distance: 0.05)
    }
    
    @IBAction func moveNegativeY(_ sender: UIButton) {
        guard selectedBlock != nil else {
            return
        }
        translateY(node: selectedBlock!, distance: -0.05)
    }
    
    @IBAction func movePositiveZ(_ sender: UIButton) {
        guard selectedBlock != nil else {
            return
        }
        translateZ(node: selectedBlock!, distance: 0.05)
    }
    
    @IBAction func moveNegstiveZ(_ sender: UIButton) {
        guard selectedBlock != nil else {
            return
        }
        translateZ(node: selectedBlock!, distance: -0.05)
    }
    
    
    //MARK: - Setter Methods for Long Lived Variables
    func setSelectedBlock(hitTestResultNode newSelectedBlock: SCNNode) -> Void {
        
        // deactive selected block if it matches the hitTestResult
        // aka a person clicked the block which was already selected
        if newSelectedBlock == selectedBlock {
            // set previously active block back to blue
            let unselectedMaterial = SCNMaterial()
            unselectedMaterial.diffuse.contents = UIColor.blue
            selectedBlock?.geometry?.materials = [unselectedMaterial]
            selectedBlock = nil
            return
        }
        
        // set previously active block back to blue
        let unselectedMaterial = SCNMaterial()
        unselectedMaterial.diffuse.contents = UIColor.blue
        selectedBlock?.geometry?.materials = [unselectedMaterial]
        
        // replace material on node to be activated to be red
        let selectedMaterial = SCNMaterial()
        selectedMaterial.diffuse.contents = UIColor.red
        
        newSelectedBlock.geometry?.materials = [selectedMaterial]
    
        selectedBlock = newSelectedBlock
    }
    
//    TODO
//    func deselectBlock(block: SCNNode) -> Void {
//        // add unselected materials
//        // set selectedBlock to nil
//    }
    
    
    //MARK: - Block Rendering Methods
    func addBlockToScene(name: String, position: SCNVector3) -> Void {
        //
        let cube = SCNBox(width: 0.05, height: 0.05, length: 0.15, chamferRadius: 0.01)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        cube.materials = [material]
        
        // create a point in 3D space, assign position, assign an object to display aka geometry
        let node = SCNNode()
        node.position = position
        node.geometry = cube
        node.name = name
        
        // add physics to block
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: node.geometry!, options: nil))
        physicsBody.mass = 0.5
        physicsBody.restitution = 0.25
        physicsBody.friction = 0.75
        physicsBody.categoryBitMask = CollisionTypes.shape.rawValue
        
        node.physicsBody = physicsBody
        
//        node.physicsBody?.isAffectedByGravity = false
        
        blocks.append(node)
        sceneView.scene.rootNode.addChildNode(node)
        print("created block \(name)")
    }
    

    //MARK: - Block Movement Methods
    func translateX(node: SCNNode, distance: CGFloat) -> Void {
        node.position.x = node.position.x + Float(distance)
    }
    
    func translateY(node: SCNNode, distance: CGFloat) -> Void {
        node.position.y = node.position.y + Float(distance)
    }
    
    func translateZ(node: SCNNode, distance: CGFloat) -> Void {
        node.position.z = node.position.z + Float(distance)
    }
    
    
    //MARK: - Plane Rendering Methods
//    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
//        // planes are always defined by x and z dimenions for horizontal plane detection, y is AWLAYS ZERO
//        // define new plan based on added anchor
//        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
//
//        let planeNode = SCNNode()
//        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
//
//        // transfrom from standard x, y to x, z
//        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
//
//
//        let gridMaterial = SCNMaterial()
////        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
//        gridMaterial.diffuse.contents = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
//
//        plane.materials = [gridMaterial]
//
//        planeNode.geometry = plane
//
//        // add as physics body, kinematic type to be stationary but still cause collisions with other bodies
//        planeNode.physicsBody = SCNPhysicsBody(
//            type: SCNPhysicsBodyType.kinematic,
//            shape: SCNPhysicsShape(geometry: planeNode.geometry!, options: nil))
//
//        return planeNode
//    }
    
    // create plane based on box
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        // planes are always defined by x and z dimenions for horizontal plane detection, y is AWLAYS ZERO
        // define new plan based on added anchor
        let plane = SCNBox(width: CGFloat(planeAnchor.extent.x), height: 0.05, length: CGFloat(planeAnchor.extent.z), chamferRadius: 0)
        
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(0, -plane.height / 2, 0)
        
        // transfrom from standard x, y to x, z
//        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        
        let gridMaterial = SCNMaterial()
        //        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        gridMaterial.diffuse.contents = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        
        // add as physics body, kinematic type to be stationary but still cause collisions with other bodies
        planeNode.physicsBody = SCNPhysicsBody(
            type: SCNPhysicsBodyType.kinematic,
            shape: SCNPhysicsShape(geometry: planeNode.geometry!, options: nil))
        
        return planeNode
    }
    
    
    //MARK: - Helper Methods
    func getNodeByName(name: String) -> SCNNode? {
        for block in blocks {
            if block.name == name {
                return block
            }
        }
        return nil
    }
}
