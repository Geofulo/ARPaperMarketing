//
//  ARMainSession.swift
//  ARPaperMarketing
//
//  Created by Geovanni Fuentes on 2024-05-27.
//

import RealityKit
import ARKit

class ARMainSession: ARView {
    static var shared = ARMainSession(frame: .zero)
    
    private var productEntity: AnchorEntity?

    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    
    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ARMainSession {
    func setup() {
        guard let imageReference = ARReferenceImage.referenceImages(inGroupNamed: "ARAssets", bundle: nil) else {
            print("Something went wrong loading reference images")
            return
        }
        
        // AR CONFIGURATION
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        configuration.detectionImages = imageReference
        configuration.maximumNumberOfTrackedImages = 1
        
        // SESSION DELEGATE
        debugOptions = [.showWorldOrigin, .showAnchorGeometry]
        session.delegate = self
        
        // START SESSION
        session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
}

extension ARMainSession: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                // PARENT ENTITY
                let parentEntity = AnchorEntity()
                
                // REFERENCE PLANE
                let size = imageAnchor.referenceImage.physicalSize
                let planeEntity = ModelEntity(mesh: .generatePlane(width: Float(size.width), depth: Float(size.height)))
                parentEntity.addChild(planeEntity)
                
                // PRODUCT MODEL
                do {
                    let modelEntity = try Entity.load(named: "mercedes_scene")
                    modelEntity.scale = [0.06, 0.06, 0.06]
                    parentEntity.addChild(modelEntity)
                } catch {
                    print("Error while adding product model entity: \(error.localizedDescription)")
                }
                
                // ADD TO SCENE
                scene.addAnchor(parentEntity)
                
                // SET ENTITY LOCALLY
                productEntity = parentEntity
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                // UPDATE PRODUCT ENTITY TRANSFORM
                guard let productEntity = productEntity else { return }
                productEntity.transform.matrix = imageAnchor.transform
            }
        }
    }
}
