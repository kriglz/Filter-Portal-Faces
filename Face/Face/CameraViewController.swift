//
//  ViewController.swift
//  Face
//
//  Created by Kristina Gelzinyte on 1/23/21.
//

import UIKit
import Metal
import MetalKit
import ARKit

extension MTKView : RenderDestinationProvider {
}

class CameraViewController: UIViewController, MTKViewDelegate, ARSessionDelegate {
    
    var configuration: ARConfiguration!
    var mtkView: MTKView!
    var session: ARSession!
    var renderer: Renderer!
    
    private let mtkBoxView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a session configuration
        let worldTrackingConfiguration = ARWorldTrackingConfiguration()
        worldTrackingConfiguration.planeDetection = [.horizontal, .vertical]
        if ARWorldTrackingConfiguration.supportsUserFaceTracking {
            worldTrackingConfiguration.userFaceTrackingEnabled = true
        }
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentation) {
            worldTrackingConfiguration.frameSemantics = .personSegmentation
        }
        let videoFormats720 = ARWorldTrackingConfiguration.supportedVideoFormats.filter({ $0.imageResolution.height == 720})
        if let videoFormat = videoFormats720.first(where: { $0.framesPerSecond == 30 }) ?? videoFormats720.first {
            worldTrackingConfiguration.videoFormat = videoFormat
        }
        configuration = worldTrackingConfiguration
        
//        let faceTrackingConfiguration = ARFaceTrackingConfiguration()
//        let videoFormats720 = ARFaceTrackingConfiguration.supportedVideoFormats.filter({ $0.imageResolution.height == 720})
//        if let videoFormat = videoFormats720.first(where: { $0.framesPerSecond == 30 }) ?? videoFormats720.first {
//            faceTrackingConfiguration.videoFormat = videoFormat
//        }
//        configuration = faceTrackingConfiguration
        
        // Set the view's delegate
        session = ARSession()
        session.delegate = self
        
        // Set the view to use the default device
        mtkView = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        mtkView.backgroundColor = UIColor.clear
        mtkView.delegate = self
        mtkView.autoResizeDrawable = true
        mtkView.framebufferOnly = false
//        mtkView.clearColor = MTLClearColor(red: 1, green: 0, blue: 0, alpha: 1)
//        mtkView.isPaused = true
        mtkView.preferredFramesPerSecond = 30
        mtkView.contentMode = .scaleAspectFill
        mtkView.clipsToBounds = true
        
        mtkBoxView.layer.masksToBounds = true
        mtkBoxView.layer.cornerRadius = 8

        guard mtkView.device != nil else {
            print("Metal is not supported on this device")
            return
        }
        
        // Configure the renderer to draw to the view
        renderer = Renderer(session: session, metalDevice: mtkView.device!, renderDestination: mtkView)
        
        renderer.drawRectResized(size: view.bounds.size)
    
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Layout
        
        mtkBoxView.addSubview(mtkView)
        view.addSubview(mtkBoxView)
        
        mtkBoxView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        
        mtkBoxView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mtkBoxView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mtkBoxView.heightAnchor.constraint(equalTo: mtkBoxView.widthAnchor, multiplier: 16.0 / 9).isActive = true
        mtkBoxView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        mtkView.leadingAnchor.constraint(equalTo: mtkBoxView.leadingAnchor).isActive = true
        mtkView.trailingAnchor.constraint(equalTo: mtkBoxView.trailingAnchor).isActive = true
        mtkView.topAnchor.constraint(equalTo: mtkBoxView.topAnchor).isActive = true
        mtkView.bottomAnchor.constraint(equalTo: mtkBoxView.bottomAnchor).isActive = true

        // Gestures
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Run the view's session
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let ratio = UIScreen.main.nativeBounds.width / 720.0
        let size = CGSize(width: 720 * ratio, height: 1280 * ratio)

        mtkView.superview?.layoutIfNeeded()
        mtkView.drawableSize = size
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        session.pause()
    }
    
    @objc
    func handleTap(gestureRecognize: UITapGestureRecognizer) {
        // Create anchor using the camera's current position
        if let currentFrame = session.currentFrame {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            session.add(anchor: anchor)
        }
    }
    
    // MARK: - MTKViewDelegate
    
    // Called whenever view changes orientation or layout is changed
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
    }
    
    // Called whenever the view needs to render
    func draw(in view: MTKView) {
        renderer.update()
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        print(frame.anchors)
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        
    }
}
