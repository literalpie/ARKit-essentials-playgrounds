//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//
//#-end-hidden-code
//: This playground shows a simple node dragging strategy


import UIKit
import PlaygroundSupport
import SceneKit

@available(iOSApplicationExtension 11.0, *)
class MyViewController : UIViewController {
    var geometryNode: SCNNode = SCNNode()

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
        let location = panGesture.location(in: self.view)
        switch panGesture.state {
        case .began:
            guard let hitNodeResult = view.hitTest(location, options: nil).first else { return }
            panStartZ = CGFloat(view.projectPoint(hitNodeResult.node.worldPosition).z)
            draggingNode = hitNodeResult.node
        case .changed:
            guard panStartZ != nil, draggingNode != nil else { return }
            let worldTouchPosition = view.unprojectPoint(SCNVector3(location.x, location.y, panStartZ!))

            geometryNode.position = worldTouchPosition
        case .ended:
            (panStartZ, draggingNode) = (nil, nil)
        default:
            break
        }
    }
}

//#-hidden-code
@available(iOSApplicationExtension 11.0, *)
extension MyViewController {
    func addBox(to scene: SCNScene) -> SCNNode {
        view.backgroundColor = .lightGray

        let cube = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 1.0)
        let cubeNode = SCNNode(geometry: cube)
        let cubeContainer = SCNNode()
        // cubeContainer will never be rotated, so we can easily translate it without rotation throwing us off.
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

        return cubeContainer

    }
}

if #available(iOSApplicationExtension 11.0, *) {
    // Present the view controller in the Live View window
    PlaygroundPage.current.liveView = MyViewController()
} else {
    // TODO: handle unsupported iOS version
}

//#-end-hidden-code
