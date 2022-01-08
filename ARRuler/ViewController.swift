//
//  ViewController.swift
//  ARRuler
//
//  Created by Micaella Morales on 1/8/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        sceneView.debugOptions = [.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            clearScreen()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            if let raycastQuery = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) {
                let results: [ARRaycastResult] = sceneView.session.raycast(raycastQuery)
                if let result = results.first {
                    addDot(at: result)
                }
            }
        }
    }
    
    func clearScreen() {
        textNode.removeFromParentNode()
        
        for dotNode in dotNodes {
            dotNode.removeFromParentNode()
        }
        dotNodes.removeAll()
    }
    
    func addDot(at result: ARRaycastResult) {
        let dotNode = SCNNode()
        dotNode.position = SCNVector3(result.worldTransform.columns.3.x,
                                      result.worldTransform.columns.3.y,
                                      result.worldTransform.columns.3.z)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        let dot = SCNSphere(radius: 0.002)
        dot.materials = [material]
        
        dotNode.geometry = dot
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        
        let textPosition = SCNVector3((start.position.x + end.position.x) * 0.5,
                                      end.position.y + 0.005,
                                      end.position.z - 0.1)
        updateText(text: "\(abs(distance) * 100) cm", at: textPosition)
    }
    
    func updateText(text: String, at position: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode.geometry = textGeometry
        textNode.position = position
        textNode.scale = SCNVector3(0.005, 0.005, 0.005)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
