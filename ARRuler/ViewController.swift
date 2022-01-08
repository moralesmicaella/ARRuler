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
        if let touchLocation = touches.first?.location(in: sceneView) {
            if let raycastQuery = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) {
                let results: [ARRaycastResult] = sceneView.session.raycast(raycastQuery)
                if let result = results.first {
                    addDot(at: result)
                }
            }
        }
    }
    
    func addDot(at result: ARRaycastResult) {
        let dotNode = SCNNode()
        dotNode.position = SCNVector3(result.worldTransform.columns.3.x,
                                      result.worldTransform.columns.3.y,
                                      result.worldTransform.columns.3.z)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        let dot = SCNSphere(radius: 0.005)
        dot.materials = [material]
        
        dotNode.geometry = dot
        
        sceneView.scene.rootNode.addChildNode(dotNode)
    }
}
