//
//  GameViewController.swift
//  SunSystem
//
//  Created by Zoom NGUYEN on 2/19/16.
//  Copyright (c) 2016 Zoom NGUYEN. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
	
	let scene = SCNScene()
	let cameraNode = SCNNode()
	let ambientLightNode = SCNNode()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// create ring
		let rings = [0, 1, 2, 3, 4, 6, 8, 10, 12]
		let diameters = [1.5, 0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 0.9, 1.0]
		let speeds = [0, 0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 0.10, 0.12]
		let planetsName = ["sun", "mecury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune"]
		
		for index in 0..<rings.count {
			
			/* Config */
			let ring = CGFloat(rings[index])
			let diameter = CGFloat(diameters[index])
			let speed = CGFloat(speeds[index])
			let planetName = String(planetsName[index])
			
			/* Ring */
			let ringGeo = SCNTorus(ringRadius: ring, pipeRadius: 0.01)
			let ringNode = SCNNode(geometry: ringGeo)
			scene.rootNode.addChildNode(ringNode)
			ringGeo.firstMaterial?.diffuse.contents = UIColor.whiteColor()
			ringNode.position = SCNVector3(x: 0, y: 0, z: 0)
			scene.rootNode.addChildNode(ringNode)
			
			/* Planet */
			let planetGeo = SCNSphere(radius: diameter)
			let planetNode = SCNNode(geometry: planetGeo)
			ringNode.addChildNode(planetNode)
			
			planetNode.position = SCNVector3(x: Float(ring), y: 0, z: 0)
			
			planetGeo.firstMaterial?.diffuse.contents = UIColor.redColor()
			planetGeo.firstMaterial?.diffuse.contents = UIImage(named: "texture_\(planetName).jpg")
			
			ringGeo.firstMaterial?.diffuse.contents = UIImage(named: "texture_\(planetName).jpg")
			
			// Action moving
			ringNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: speed, z: 0, duration: 1)))
			planetNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: speed, z: 0, duration: 1)))
			
			planetNode.castsShadow = true
            
            // Add planet's name
            let nameText = SCNText(string:planetName, extrusionDepth: 0.001)
            nameText.firstMaterial?.diffuse.contents  = UIColor.whiteColor()
            nameText.font = UIFont(name: "Arial", size: 14)
            nameText.wrapped = true
            nameText.alignmentMode = kCAAlignmentRight
            
            let nameNode = SCNNode(geometry: nameText)
            nameNode.scale = SCNVector3Make(0.02, 0.02, 0.02)
            nameNode.position = SCNVector3(x: Float(ring), y: Float(diameter) + 0.1, z: 0)
            
            ringNode.addChildNode(nameNode)
            
			
			if (index == 0) {// Sun
				planetNode.light = SCNLight()
				planetNode.light!.type = SCNLightTypeOmni
				planetNode.light!.color = UIColor.whiteColor()
			}
			else {
				// Remove effect of ambient light
				planetNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = false
				planetNode.geometry?.firstMaterial?.ambient.contents = UIColor.blackColor()

				if (index == 3) {// Earth
					// Draw Ring Moon
					let ringMoon = SCNTorus(ringRadius: 0.7, pipeRadius: 0.005)
					let ringMoonNode = SCNNode(geometry: ringMoon)
					planetNode.addChildNode(ringMoonNode)
					
					ringMoon.firstMaterial?.diffuse.contents = UIColor.whiteColor()
					ringMoonNode.position = SCNVector3(x: 0, y: 0.0, z: 0.2)
					
					// Draw Moon
					let moonGeo = SCNSphere(radius: 0.1)
					let moonNode = SCNNode(geometry: moonGeo)
					ringMoonNode.addChildNode(moonNode)
					
					moonNode.position = SCNVector3(x: Float(0.7), y: 0, z: 0)
					moonGeo.firstMaterial?.diffuse.contents = UIImage(named: "texture_moon.jpg")
					
					// Moving Moon
					ringMoonNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: speed, z: 0, duration: 1)))
				}
				
			}
			// create and add a camera to the scene
			
			cameraNode.camera = SCNCamera()
			scene.rootNode.addChildNode(cameraNode)
			
			// place the camera
			cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
			
			// create and add an ambient light to the scene
			ambientLightNode.light = SCNLight()
			ambientLightNode.light!.type = SCNLightTypeAmbient
			ambientLightNode.light!.color = UIColor.whiteColor()
			scene.rootNode.addChildNode(ambientLightNode)
			
			// retrieve the SCNView
			let scnView = self.view as! SCNView
			
			// set the scene to the view
			scnView.scene = scene
			
			// allows the user to manipulate the camera
			scnView.allowsCameraControl = true
			
			// show statistics such as fps and timing information
			scnView.showsStatistics = false
			
			// configure the view
			scnView.backgroundColor = UIColor.blackColor()
			
			// add a tap gesture recognizer
			let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
			scnView.addGestureRecognizer(tapGesture)
			
			//
			scene.background.contents = UIImage(named: "background.jpg")
		}
    }
		
		func handleTap(gestureRecognize: UIGestureRecognizer) {
			// retrieve the SCNView
			let scnView = self.view as! SCNView
			
			// check what nodes are tapped
			let p = gestureRecognize.locationInView(scnView)
			let hitResults = scnView.hitTest(p, options: nil)
			// check that we clicked on at least one object
			if hitResults.count > 0 {
				// retrieved the first clicked object
				let result: AnyObject! = hitResults[0]
				
				// get its material
				let material = result.node!.geometry!.firstMaterial!
				
				// Change camera to object
				
				// highlight it
				SCNTransaction.begin()
				SCNTransaction.setAnimationDuration(0.5)
				
				// on completion - unhighlight
				SCNTransaction.setCompletionBlock {
					SCNTransaction.begin()
					SCNTransaction.setAnimationDuration(0.5)
					
					material.emission.contents = UIColor.blackColor()
					
					SCNTransaction.commit()
				}
				
				material.emission.contents = UIColor.redColor()
				
				SCNTransaction.commit()
			}
		}
		
		override func shouldAutorotate() -> Bool {
			return true
		}
		
		override func prefersStatusBarHidden() -> Bool {
			return true
		}
		
		override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
			if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
				return .AllButUpsideDown
			} else {
				return .All
			}
		}
		
		override func didReceiveMemoryWarning() {
			super.didReceiveMemoryWarning()
			// Release any cached data, images, etc that aren't in use.
		}
	}
