
public extension VideoCapture {
  public struct Constraints {
    let width:Int?
    let height:Int?
    let pixelFormat:VideoDevice.PixelFormat?
    let resetCrop:Bool = false
  }
}
