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
    
    
    //MARK: - Gesture Methods
    @objc func tap(sender: UITapGestureRecognizer) -> Void {
        print("tapped")
        
        let touchLocation = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(touchLocation)
        
        if let hitTestResult = hitTestResults.first {
            print(hitTestResult.node.name)
            
            setSelectedBlock(hitTestResultNode: hitTestResult.node)
            
            print(selectedBlock)
        }
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
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
    
    
    //MARK: -
    func setSelectedBlock(hitTestResultNode newSelectedBlock: SCNNode) -> Void {
       
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
    
    
    //MARK: - Helper Methods
    func getNodeByName(name: String) -> SCNNode? {
        for block in blocks {
            if block.name == name {
                return block
            }
        }
        return nil
    }
    
    func addBlockToScene(name: String, position: SCNVector3) -> Void {
        let cube = SCNBox(width: 0.05, height: 0.05, length: 0.15, chamferRadius: 0.01)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        cube.materials = [material]
        
        // create a point in 3D space, assign position, assign an object to display aka geometry
        let node = SCNNode()
        node.position = position
        node.geometry = cube
        node.name = name
        
        blocks.append(node)
        sceneView.scene.rootNode.addChildNode(node)
    }
}
