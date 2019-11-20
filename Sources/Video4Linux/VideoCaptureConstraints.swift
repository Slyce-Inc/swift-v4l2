
public extension VideoCapture {
  struct Constraints {
    let width:Int?
    let height:Int?
    let pixelFormat:VideoDevice.PixelFormat?
    let resetCrop:Bool = false
  }
}
