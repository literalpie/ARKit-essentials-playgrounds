//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import SceneKit

class MyViewController : UIViewController {
    var currentAngle: Float = 0.0
    var geometryNode: SCNNode = SCNNode()

    // the location of the touch point in the scene when the last movement happened
    var lastPanLocation: SCNVector3?
    // the z poisition of the dragging point
    var panStartZ: CGFloat?
    // the node being dragged
    var draggingNode: SCNNode?
    

    override func loadView() {
        view = SCNView()
        let scene = SCNScene()
        (view as! SCNView).scene = scene

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(panGesture:)))
        view.addGestureRecognizer(panRecognizer)

        geometryNode = addBox(to: scene)
    }

    @objc func panGesture(panGesture: UIPanGestureRecognizer) {
        guard let view = view as? SCNView else { return }
        switch panGesture.state {
        case .began:
            let location = panGesture.location(in: self.view)
            guard let hitNodeResult = view.hitTest(location, options: nil).first else { return }
            lastPanLocation = hitNodeResult.worldCoordinates
            panStartZ = CGFloat(view.projectPoint(lastPanLocation!).z)
            draggingNode = hitNodeResult.node
        case .changed:
            let location = panGesture.location(in: view)
            // the touch has moved and this variable is the new position in 3d space that the touch is at.
            // We use the panStartZ and never change it because panning should never change the z position (relative to the camera)
            // This is similar to getting the hitTest location of the gesture again,
            // but does not require the gesture to still intersect with the dragging object.
            let worldTouchPosition = view.unprojectPoint(SCNVector3(location.x, location.y, panStartZ!))

            // The amount to move the box by is the amount between the last touch point and the new one (in 3d scene space)
            let movementVector = SCNVector3(worldTouchPosition.x - lastPanLocation!.x,
                                            worldTouchPosition.y - lastPanLocation!.y,
                                            worldTouchPosition.z - lastPanLocation!.z)
            geometryNode.localTranslate(by: movementVector)
//            geometryNode.translateIgnoringRotation(by: movementVector)

            self.lastPanLocation = worldTouchPosition

        default:
            break
        }
    }


    func addBox(to scene: SCNScene) -> SCNNode {
        view.backgroundColor = .lightGray

        let cube = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 1.0)
        let cubeNode = SCNNode(geometry: cube)
        let cubeContainer = SCNNode()
        // cubeContainer will never be rotated, so we can easily translate it without ignoring rotation.
        cubeContainer.addChildNode(cubeNode)
        cubeNode.worldTransform
        cubeNode.rotate(by: .init(0.5, 0, 0, 1), aroundTarget: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cubeContainer)
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor(white: 0.4, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)

        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = .omni
        omniLightNode.light!.color = UIColor(white: 0.5, alpha: 1.0)
        omniLightNode.position = SCNVector3Make(0, 50, 50)
        scene.rootNode.addChildNode(omniLightNode)


        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 25)
        scene.rootNode.addChildNode(cameraNode)

        // to translate without rotation (better performance), return cubeContainer.
        // to show translation while correcting for rotation (worse performance), return cubeNode
        // and use correct tranform function in the gestureChanged function above.
        return cubeContainer

    }
}

extension SCNNode {
    func translateIgnoringRotation(by translation: SCNVector3) {
        let rotation = self.rotation
        let placeholderNode = SCNNode()
        placeholderNode.isHidden = true
        placeholderNode.transform = self.transform
        placeholderNode.rotation = .init(0, 0, 0, 0)
        placeholderNode.localTranslate(by: translation)
        placeholderNode.rotation = rotation
        self.transform = placeholderNode.transform

    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
