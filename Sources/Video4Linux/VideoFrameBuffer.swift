import Glibc


public class VideoFrameBuffer {
  public let baseAddress: UnsafeMutableRawPointer
  public let length: Int

  public init(baseAddress:UnsafeMutableRawPointer, length:Int) {
    self.baseAddress = baseAddress
    self.length = length
  }
}
