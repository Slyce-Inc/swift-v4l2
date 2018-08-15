import Glibc
import Clibv4l2


public class VideoDevice {
  public let pathToFile:String
  let fileDescriptor:Int32

  private init(pathToFile:String, fileDescriptor:Int32) {
    self.pathToFile = pathToFile
    self.fileDescriptor = fileDescriptor
  }

  deinit {
    close(fileDescriptor)
  }

  public class func open(pathToFile:String) throws -> VideoDevice {
    var st = stat()
    guard -1 != stat(pathToFile, &st) else {
      guard let rawSystemMessage = strerror(errno), let systemMessage = String(cString:rawSystemMessage, encoding:.utf8) else {
        throw VideoDeviceError.UnableToOpenDevice(pathToFile:pathToFile, message:"\(errno)")
      }
      throw VideoDeviceError.UnableToOpenDevice(pathToFile:pathToFile, message:"\(systemMessage) (\(errno))")
    }
    guard 0 != (S_IFCHR & st.st_mode) else {
      throw VideoDeviceError.UnableToOpenDevice(pathToFile:pathToFile, message:"Not a character device")
    }
    guard case let fd = Glibc.open(pathToFile, O_RDWR | O_NONBLOCK, 0), fd > 0 else {
      throw VideoDeviceError.UnableToOpenDevice(pathToFile:pathToFile, message:"\(errno), \(strerror(errno))")
    }
    return VideoDevice(pathToFile:pathToFile, fileDescriptor:fd)
  }

  private lazy var capabilities: v4l2_capability = {
    var cap = v4l2_capability()
    _ = ioctl(self.fileDescriptor, _VIDIOC_QUERYCAP, &cap)
    return cap
  }()

  public var canCapture:Bool {
    return 0 != (self.capabilities.capabilities & UInt32(V4L2_CAP_VIDEO_CAPTURE))
  }

  public var canStream:Bool {
    return 0 != (self.capabilities.capabilities & UInt32(V4L2_CAP_STREAMING))
  }
}
