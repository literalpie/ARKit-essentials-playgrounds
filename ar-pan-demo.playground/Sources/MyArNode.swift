import SceneKit

public class MyArNode: SCNNode {
    public var pannable = false
    public var pinchable = false
    public var rotatable = false

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init() {
        super.init()
    }

    public convenience init(pannable: Bool = false, pinchable: Bool = false, rotatable: Bool = false) {
        self.init()
        (self.pannable, self.pinchable, self.rotatable) = (pannable, pinchable, rotatable)
    }
}
