import UIKit
import ARKit

public class MyArView: ARSCNView, UIGestureRecognizerDelegate {
    var lastPanPosition: SCNVector3?
    var panningNode: SCNNode?
    var panStartZ: CGFloat?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override init(frame: CGRect, options: [String: Any]? = nil) {
        super.init(frame: frame, options: options)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public func setup() {
        let recognizer = UIPanGestureRecognizer(target: self,
                                                action: #selector(handleThePan(gestureRecognizer:)))
        recognizer.delegate = self
        self.addGestureRecognizer(recognizer)
    }
    
    // The parent-child node needs to be combined into one so we don't have to do weird stuff to detect it
    @objc func handleThePan(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            let location = gestureRecognizer.location(in: self)
            guard let hitNodeResult = hitTest(location, options: nil).first else { return }
            lastPanPosition = hitNodeResult.worldCoordinates
            panningNode = hitNodeResult.node
            panStartZ = CGFloat(projectPoint(lastPanPosition!).z)
        case .changed:
            guard lastPanPosition != nil, panningNode != nil, panStartZ != nil else { return }
            let location = gestureRecognizer.location(in: self)
            // the touch has moved and this variable is the new position in 3d space that the touch is at.
            // We use the panStartZ and never change it because panning should never change the z position (relative to the camera)
            // This is similar to getting the hitTest location of the gesture again,
            // but does not require the gesture to still intersect with the dragging object.
            let worldTouchPosition = unprojectPoint(SCNVector3(location.x, location.y, panStartZ!))

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

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
