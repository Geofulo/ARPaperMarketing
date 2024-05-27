//
//  ARViewContainer.swift
//  ARPaperMarketing
//
//  Created by Geovanni Fuentes on 2024-05-27.
//

import SwiftUI
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARMainSession.shared
        arView.setup()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
}
