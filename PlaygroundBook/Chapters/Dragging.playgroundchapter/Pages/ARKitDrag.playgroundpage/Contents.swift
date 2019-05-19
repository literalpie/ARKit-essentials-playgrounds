//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//
//#-end-hidden-code

//: IMPORTANT: To avoid terrible performance, turn off "enable results" (found by tapping the button that looks like a spedometer)
//:
//: Tap the view to add a box in front of the camera. drag a box to move it around.


import UIKit
import PlaygroundSupport
import SceneKit
import ARKit

@available(iOSApplicationExtension 11.0, *)
class MyViewController : UIViewController, ARSCNViewDelegate, ARSessionDelegate, UIGestureRecognizerDelegate {
    var lastPanPosition: SCNVector3?
    var panningNode: SCNNode?
    var panStartZ: CGFloat?
    let arView = ARSCNView()

    override func loadView() {
        view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 800, height: 500)))

        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(handleTheTap(tapGesture:)))
        tapRecognizer.delegate = self
        arView.addGestureRecognizer(tapRecognizer)

        let panRecognizer = UIPanGestureRecognizer(target: self,
                                                action: #selector(handleThePan(gestureRecognizer:)))
        panRecognizer.delegate = self
        arView.addGestureRecognizer(panRecognizer)

        arView.frame = view.frame
        view.addSubview(arView)

        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)
        arView.delegate = self
        arView.session.delegate = self
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let cube = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.0)
        let node = MyArNode(pannable: true)
        node.geometry = cube
        node.rotate(by: .init(0.5, 0, 0, 1), aroundTarget: SCNVector3(0,0,0))
        return node
    }

    @objc func handleTheTap(tapGesture: UITapGestureRecognizer) {
        let anchor = addAnchorInFront()
        arView.session.add(anchor: anchor)
    }

    @objc func handleThePan(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            let location = gestureRecognizer.location(in: arView)
            guard let hitNodeResult = arView.hitTest(location, options: nil).first else { return }
            lastPanPosition = hitNodeResult.worldCoordinates
            panningNode = hitNodeResult.node
            panStartZ = CGFloat(arView.projectPoint(lastPanPosition!).z)
        case .changed:
            guard lastPanPosition != nil, panningNode != nil, panStartZ != nil else { return }
            let location = gestureRecognizer.location(in: arView)

            // the touch has moved and worldTouchPosition is the new position in 3d space that the touch is at.
            // We use the panStartZ and never change it because panning should never change the z position (relative to the camera)
            // This is similar to getting the hitTest location of the gesture again,
            // but does not require the gesture to still intersect with the dragging object.
            let worldTouchPosition = arView.unprojectPoint(SCNVector3(location.x, location.y, panStartZ!))

            let movementVector = SCNVector3(worldTouchPosition.x - lastPanPosition!.x,
                                            worldTouchPosition.y - lastPanPosition!.y,
                                            worldTouchPosition.z - lastPanPosition!.z)
            panningNode?.localTranslate(by: movementVector)

            self.lastPanPosition = worldTouchPosition
        case .ended:
            (lastPanPosition, panningNode, panStartZ) = (nil, nil, nil)
        default:
            return
        }
    }
}

//#-hidden-code
@available(iOSApplicationExtension 11.0, *)
extension MyViewController {
    // adds an ARAnchor a little bit in front of the camera.
    func addAnchorInFront() -> ARAnchor {
        let midPoint = CGPoint(x: arView.frame.width / 2.0, y: arView.frame.height / 2.0)
        var labelTransform = matrix_identity_float4x4
        let point = arView.unprojectPoint(SCNVector3(midPoint.x, midPoint.y, 0.9986377))
        labelTransform.columns.3.x = point.x
        labelTransform.columns.3.y = point.y
        labelTransform.columns.3.z = point.z
        let newAnchor = ARAnchor(transform: labelTransform)

        return newAnchor
    }
}

@available(iOSApplicationExtension 11.0, *)
public class MyArNode: SCNNode {
    public var pannable = false

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init() {
        super.init()
    }

    public convenience init(pannable: Bool = false) {
        self.init()
        self.pannable = pannable
    }
}

if #available(iOSApplicationExtension 11.0, *) {
    // Present the view controller in the Live View window
    let viewController = MyViewController()
    viewController.loadView()

    PlaygroundPage.current.liveView = viewController
} else {
    // TODO: handle unsupported iOS version
}
//#-end-hidden-code
