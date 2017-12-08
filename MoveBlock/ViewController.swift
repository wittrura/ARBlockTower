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
        
        
//        addBlockToScene(name: "block1", position: SCNVector3(x: 0, y: 0.1, z: -0.5)) // -z axis is AWAY from user
//        addBlockToScene(name: "block2", position: SCNVector3(x: 0, y: -0.1, z: -0.5)) // -z axis is AWAY from user
//        addBlockToScene(name: "block3", position: SCNVector3(x: 0.1, y: 0.1, z: -0.5)) // -z axis is AWAY from user
        
        
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
//    }
//
//    func updatePlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> Void {
//        // expand currently detected plane
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
        
        //TODO - delete and create build tower button
        let hitTestResultsPlane = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if let hitTestResultPlane = hitTestResultsPlane.first {
            
            // use tap location as base for building tower
            let position = SCNVector3Make(
                hitTestResultPlane.worldTransform.columns.3.x,
                hitTestResultPlane.worldTransform.columns.3.y, // block appears to be slightly higer than plane
                hitTestResultPlane.worldTransform.columns.3.z)
            addBlocksToScene(initialPosition: position, numRows: 4)
        }
        //TODO - delete and create build tower button
        
        
        // handle taps on blocks
        if let hitTestResult = hitTestResults.first {
            // only select objects with 'block' in their name, guard against accidentally activating featurePoints and planes
            // TODO - create Block class for checks rather than name property
            guard let name = hitTestResult.node.name?.contains("block") else {
                return
            }
            setSelectedBlock(hitTestResultNode: hitTestResult.node)
        }
    }
    
    
    //MARK: - Button Methods
    @IBAction func movePositiveX(_ sender: UIButton) {
        guard selectedBlock != nil else {
            return
        }
        if (selectedBlock?.physicsBody?.isAffectedByGravity)! {
            applyForceX(node: selectedBlock!, magnitude: 0.25)
        } else {
            translateX(node: selectedBlock!, distance: 0.01)
        }
    }
    
    @IBAction func moveNegativeX(_ sender: UIButton) {
        guard selectedBlock != nil else {
            return
        }
        if (selectedBlock?.physicsBody?.isAffectedByGravity)! {
            applyForceX(node: selectedBlock!, magnitude: -0.25)
        } else {
            translateX(node: selectedBlock!, distance: -0.01)
        }
    }
    
    @IBAction func movePositiveY(_ sender: UIButton) {
        guard selectedBlock != nil else {
            return
        }
        translateY(node: selectedBlock!, distance: 0.01)
    }
    
    @IBAction func moveNegativeY(_ sender: UIButton) {
        guard selectedBlock != nil else {
            return
        }
        translateY(node: selectedBlock!, distance: -0.01)
    }
    
    @IBAction func movePositiveZ(_ sender: UIButton) {
        guard selectedBlock != nil else {
            return
        }
        if (selectedBlock?.physicsBody?.isAffectedByGravity)! {
            applyForceZ(node: selectedBlock!, magnitude: 0.25)
        } else {
            translateZ(node: selectedBlock!, distance: 0.01)
        }
    }
    
    @IBAction func moveNegativeZ(_ sender: UIButton) {
        guard selectedBlock != nil else {
            return
        }
        if (selectedBlock?.physicsBody?.isAffectedByGravity)! {
            applyForceZ(node: selectedBlock!, magnitude: -0.25)
        } else {
            translateZ(node: selectedBlock!, distance: -0.01)
        }
    }
    
    @IBAction func rotateClockwise(_ sender: UIButton) {
        guard (selectedBlock != nil) else {
            return
        }
        rotateBlock(node: selectedBlock!)
    }
    
    @IBAction func clearBlocks(_ sender: UIButton) {
        deleteNodes(fromArr: blocks)
    }
    
    @IBAction func addPhysicsToBlocks(_ sender: UIButton) {
        addPhysicsToTower()
    }
    
    
    //MARK: - Block Rendering Methods
    func addBlockToScene(name: String, position: SCNVector3) -> Void {
        // set up geometry size and color
        let cube = SCNBox(width: 0.02, height: 0.02, length: 0.05, chamferRadius: 0.001)
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
        physicsBody.mass = 0.5  // weight in kg
        physicsBody.restitution = 0.25 // bounciness
        physicsBody.friction = 0.50 // default value, 0 = easy movement, 1.0 = no movement
//        physicsBody.damping = 1.0
        
        physicsBody.categoryBitMask = CollisionTypes.shape.rawValue
        
        node.physicsBody = physicsBody
//        node.physicsBody?.isAffectedByGravity = false
        
        
        blocks.append(node)
        sceneView.scene.rootNode.addChildNode(node)
//        print("created block \(name)")
    }
    
    
    // for constructing tower, adds block with physics and variable length / width
    func addBlockToScene(name: String, position: SCNVector3, length: CGFloat, width: CGFloat) -> Void {
        // set up geometry size and color
        let cube = SCNBox(width: width, height: 0.02, length: length, chamferRadius: 0.001)
        
        let material = SCNMaterial()
        material.diffuse.contents = randomWoodTexture()
        cube.materials = [material]
        
        // create a point in 3D space, assign position, assign an object to display aka geometry
        let node = SCNNode()
        node.position = position
        node.geometry = cube
        node.name = name
        
        // add physics to block
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: node.geometry!, options: nil))
        physicsBody.mass = 0.5  // weight in kg
        physicsBody.restitution = 0.0 // bounciness
        physicsBody.friction = 0.5 // default value, 0 = easy movement, 1.0 = no movement
//        physicsBody.damping = 0.75
        
        physicsBody.categoryBitMask = CollisionTypes.shape.rawValue
        
        node.physicsBody = physicsBody
//        node.physicsBody?.isAffectedByGravity = false
        
        blocks.append(node)
        sceneView.scene.rootNode.addChildNode(node)
//        print("created block \(name)")
    }
    
    // randomly select one of the three wood textures to be applied to diffuse contents
    func randomWoodTexture() -> UIImage {
        let randomNum = arc4random_uniform(3) + 1
        
        var wood = UIImage(named: "art.scnassets/wood1.png")
        
        if randomNum > 2 {
            wood = UIImage(named: "art.scnassets/wood1.png")
        } else if randomNum < 1 {
            wood = UIImage(named: "art.scnassets/wood2.png")
        } else {
            wood = UIImage(named: "art.scnassets/wood3.jpg")
        }
        
        return wood!
    }
    
    
    //MARK: - Tower Building Methods
    var buildTowerCurrentRowBaseVector = SCNVector3()
    var blockWidth = CGFloat(0.02)
    var blockHeight = CGFloat(0.02)
    var blockLength = CGFloat(0.06)
    var buildTowerInX = true
    
    func addBlocksToScene(initialPosition position: SCNVector3, numRows: Int) -> Void {
        print("tap position: ", position)
        
        if blocks.count > 0 {
            print("blocks already present")
            return
        }
        
        buildTowerCurrentRowBaseVector = SCNVector3Make(position.x, position.y, position.z)
        
        for i in 1...numRows {
            // TODO - refactor, to use base as center for a row, add block, then add to left AND right
            var currentRowReferenceVector = SCNVector3Make(
                buildTowerCurrentRowBaseVector.x,
                buildTowerCurrentRowBaseVector.y + Float(blockHeight / 2),
                buildTowerCurrentRowBaseVector.z)
            
            addBlockToScene(name: "block_\(i).1", position: currentRowReferenceVector, length: blockLength, width: blockWidth)
            if buildTowerInX {
                currentRowReferenceVector.x += Float(blockWidth)
            } else {
                currentRowReferenceVector.z += Float(blockLength)
            }
            
            addBlockToScene(name: "block_\(i).2", position: currentRowReferenceVector, length: blockLength, width: blockWidth)
            if buildTowerInX {
                currentRowReferenceVector.x += Float(blockWidth)
            } else {
                currentRowReferenceVector.z += Float(blockLength)
            }
            
            addBlockToScene(name: "block_\(i).3", position: currentRowReferenceVector, length: blockLength, width: blockWidth)
            if buildTowerInX {
                // position, x + width, z - width, y + height
                buildTowerCurrentRowBaseVector.x += Float(blockWidth)
                buildTowerCurrentRowBaseVector.y += Float(blockHeight)
                buildTowerCurrentRowBaseVector.z -= Float(blockWidth)
            } else {
                // position, x - width, z + width, y + height
                buildTowerCurrentRowBaseVector.x -= Float(blockLength)
                buildTowerCurrentRowBaseVector.y += Float(blockHeight)
                buildTowerCurrentRowBaseVector.z += Float(blockLength)
            }
            
            // rotation orientation 90 degrees
            let _blockWidth = blockWidth
            blockWidth = blockLength
            blockLength = _blockWidth

            buildTowerInX = !buildTowerInX
        }
        
//        addPhysicsToTower()
        
        // TODO - DELETE
        buildTowerCurrentRowBaseVector = SCNVector3()
        blockWidth = CGFloat(0.02)
        blockHeight = CGFloat(0.02)
        blockLength = CGFloat(0.06)
        buildTowerInX = true
        // TODO - DELETE
    }
    
    
    func addPhysicsToTower() -> Void {
        for block in blocks {
            applyPhysics(to: block)
        }
    }
    
    
    func applyPhysics(to node: SCNNode) -> Void {
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: node.geometry!, options: nil))
        physicsBody.mass = 0.01  // weight in kg
        physicsBody.restitution = 0.05 // bounciness
        physicsBody.friction = 1.0 // default value, 0 = easy movement, 1.0 = no movement
//        physicsBody.damping = 1.0
        
        physicsBody.categoryBitMask = CollisionTypes.shape.rawValue
        
        node.physicsBody = physicsBody
        node.physicsBody?.isAffectedByGravity = true
    }
    
    
    //MARK: - Block Movement Methods
    func translateX(node: SCNNode, distance: CGFloat) -> Void {
        node.position = node.presentation.position
        
        node.position.x = node.position.x + Float(distance)
    }

    func translateY(node: SCNNode, distance: CGFloat) -> Void {
        // disable gravity effect to allow translation in y direction for placing blocks
        node.physicsBody?.isAffectedByGravity = false
        
        node.position = node.presentation.position
        
        node.position.y = node.position.y + Float(distance)
    }
    
    func translateZ(node: SCNNode, distance: CGFloat) -> Void {
        node.position = node.presentation.position
        
        node.position.z = node.position.z + Float(distance)
    }
    
    
    func applyForceX(node: SCNNode, magnitude: Float) -> Void {
        node.physicsBody?.applyForce(SCNVector3Make(magnitude, 0, 0), asImpulse: true)
    }
    
    func applyForceY(node: SCNNode, magnitude: Float) -> Void {
        node.physicsBody?.applyForce(SCNVector3Make(0, magnitude, 0), asImpulse: false)
    }
    
    func applyForceZ(node: SCNNode, magnitude: Float) -> Void {
        node.physicsBody?.applyForce(SCNVector3Make(0, 0, magnitude), asImpulse: true)
    }
    
    func rotateBlock(node: SCNNode) -> Void {
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi / 2), z: 0, duration: 0.01)
        
        // set node location to match the location of its presentation node, which is a 'copy' of the intially created note
        // that provides the representation of what is rendered
        node.position = node.presentation.position
        node.runAction(action)
        
        // apply physics force to end of block
//        node.physicsBody?.applyForce(SCNVector3(0, 0, -1), at: SCNVector3(0,0,0), asImpulse: true)
    }
    
    
    //MARK: - Plane Rendering Methods
    // create plane based on SCNBox instead of standard SCNPlane
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
//        // planes are always defined by x and z dimenions for horizontal plane detection, y is AWLAYS ZERO
//        // define new plan based on added anchor
//        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        // define new plane BOX based on added anchor, using x and z dimensions from the detected anchor
        // SCNBox allows for better collision with blocks
        let plane = SCNBox(width: CGFloat(planeAnchor.extent.x), height: 0.01, length: CGFloat(planeAnchor.extent.z), chamferRadius: 0)
        
        // create plane node slightly below y = 0 to account for height
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(0, -(plane.height / 2), 0)
        
        // shade light blue
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        
        // add as physics body, kinematic type to be stationary but still cause collisions with other bodies
        planeNode.physicsBody = SCNPhysicsBody(
            type: SCNPhysicsBodyType.kinematic,
            shape: SCNPhysicsShape(geometry: planeNode.geometry!, options: nil))
        
        
        planeNode.physicsBody?.friction = 1.0
        planeNode.physicsBody?.restitution = 0.0
//        planeNode.physicsBody?.damping = 1.0
        
        return planeNode
    }
    
    
    //MARK: - Setter Methods for Long Lived Variables
    func setSelectedBlock(hitTestResultNode newSelectedBlock: SCNNode) -> Void {
        
        // deactive selected block if it matches the hitTestResult
        // aka a person clicked the block which was already selected
        if newSelectedBlock == selectedBlock {
            deselectBlock()
            return
        }
        
        // set previously active block back to blue
        deselectBlock()
        
        // replace material on node to be activated to be red
        let selectedMaterial = SCNMaterial()
        selectedMaterial.diffuse.contents = UIImage(named: "art.scnassets/redWood1.jpg")
        
        newSelectedBlock.geometry?.materials = [selectedMaterial]
        
        
        // deactivate gravity, to allow movement vertically
//        newSelectedBlock.physicsBody?.isAffectedByGravity = false
        
        selectedBlock = newSelectedBlock
    }
    
    // set previously active block back to wood texture
    func deselectBlock() -> Void {
        guard selectedBlock != nil else {
            return
        }
        
        let unselectedMaterial = SCNMaterial()
        unselectedMaterial.diffuse.contents = randomWoodTexture()
        
        selectedBlock!.geometry?.materials = [unselectedMaterial]
        
        // reactivate gravity, to allow movement vertically
        selectedBlock!.physicsBody?.isAffectedByGravity = true
        
        selectedBlock = nil
    }
    
    // removes nodes from parent, for blocks this is to remove from sceneview's root node
    func deleteNodes(fromArr arr: [SCNNode]) -> Void {
        for node in arr {
            node.removeFromParentNode()
        }
        clearBlocksArr()
    }
    
    // hard delete to empty the blocks array which stores created nodes
    func clearBlocksArr() -> Void {
        blocks = [SCNNode]()
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
