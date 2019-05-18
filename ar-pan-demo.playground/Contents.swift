// Note: For performance reasons, the important code is in the MyArView auxillary file.
  
import UIKit
import ARKit
import PlaygroundSupport

class MyViewController : UIViewController, ARSCNViewDelegate, ARSessionDelegate, UIGestureRecognizerDelegate {
    let arView = MyArView()
    override func loadView() {
        view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 800, height: 500)))
        arView.setup()
        arView.frame = view.frame
        view.addSubview(arView)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection =  [.horizontal, .vertical]
        arView.session.run(config)
        arView.delegate = self
        arView.session.delegate = self
        
//        let anchor = arView.addAnchorInFront()
        let anchor = ARAnchor(transform: simd_float4x4())
        arView.session.add(anchor: anchor)

        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTheTap(tapGesture:)))
        recognizer.delegate = self
        arView.addGestureRecognizer(recognizer)
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


    func addAnchorInFront() -> ARAnchor {
        let midPoint = CGPoint(x: arView.frame.width / 2.0, y: arView.frame.height / 2.0)
        var labelTransform = matrix_identity_float4x4
        let point = arView.unprojectPoint(SCNVector3(midPoint.x, midPoint.y, 0.9986377))
        labelTransform.columns.3.x = point.x
        labelTransform.columns.3.y = point.y
        labelTransform.columns.3.z = point.z
        // hello to you again
        let newAnchor = ARAnchor(transform: labelTransform)

        return newAnchor
    }
}
// Present the view controller in the Live View window
// PlaygroundPage.current.liveView = MyViewController()
let viewController = MyViewController()
viewController.loadView()

PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution =  true
