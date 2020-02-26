import Clibv4l2
import Glibc
import Foundation


public class VideoCapture {
  public let device:VideoDevice
  private let buffers: [VideoFrameBuffer]
  private let format: v4l2_format
  private var source: DispatchSourceRead?

  init(device:VideoDevice, buffers:[VideoFrameBuffer], format:v4l2_format) {
    self.device = device
    self.buffers = buffers
    self.format = format
  }

  public var width: Int {
    return Int(format.fmt.pix.width)
  }

  public var height: Int {
    return Int(format.fmt.pix.height)
  }

  deinit {
    stopStreaming()

    for buffer in buffers {
      munmap(buffer.baseAddress, buffer.length)
    }
  }

  public func startStreaming(queue:DispatchQueue = .main, handler:@escaping (UnsafeMutableRawPointer,Int)->()) throws {
    for i in 0 ..< buffers.count {
      var buf = v4l2_buffer()
      buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE.rawValue
      buf.memory = V4L2_MEMORY_MMAP.rawValue
      buf.index = UInt32(i)

      if -1 == ioctl(device.fileDescriptor, _VIDIOC_QBUF, &buf) {
        throw VideoDeviceError.UnableToQueueBuffer(device:device)
      }
    }

    var type = V4L2_BUF_TYPE_VIDEO_CAPTURE.rawValue
    if -1 == ioctl(device.fileDescriptor, _VIDIOC_STREAMON, &type) {
      throw VideoDeviceError.UnableToEnableStreaming(device:device)
    }
 
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      var statbuf = stat()
      while let this = self {
        guard 0 >= fstat(this.device.fileDescriptor, &statbuf) else {
          continue
        }
        var buf = v4l2_buffer()
        buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE.rawValue
        buf.memory = V4L2_MEMORY_MMAP.rawValue
        if -1 != ioctl(this.device.fileDescriptor, _VIDIOC_DQBUF, &buf) {
          handler(this.buffers[Int(buf.index)].baseAddress, Int(buf.bytesused))
          _ = ioctl(this.device.fileDescriptor, _VIDIOC_QBUF, &buf)
        }
      }
      print("stopping.")
    }
  }

  public func stopStreaming() {
    self.source?.cancel()
    self.source = nil

    var type = V4L2_BUF_TYPE_VIDEO_CAPTURE.rawValue
    _ = ioctl(device.fileDescriptor, _VIDIOC_STREAMOFF, &type)
  }
}


extension VideoDevice {
  public func startCapture(constraints:VideoCapture.Constraints? = nil, numberOfBuffers:Int = 8) throws -> VideoCapture {
    guard self.canCapture else {
      throw VideoDeviceError.DeviceIsNotCapableOfCapture(device:self)
    }
    guard self.canStream else {
      throw VideoDeviceError.DeviceIsNotCapableOfStreaming(device:self)
    }

    if let resetCrop = constraints?.resetCrop, resetCrop {
      var cropcap = v4l2_cropcap()
      cropcap.type = V4L2_BUF_TYPE_VIDEO_CAPTURE.rawValue
      if 0 == ioctl(self.fileDescriptor, _VIDIOC_CROPCAP, &cropcap) {
        var crop = v4l2_crop()
        crop.type = V4L2_BUF_TYPE_VIDEO_CAPTURE.rawValue
        crop.c = cropcap.defrect /* reset to default */

        if -1 == ioctl(self.fileDescriptor, UInt(_VIDIOC_S_CROP), &crop) {
          switch (errno) {
          case EINVAL:
            /* Cropping not supported. */
            break
          default:
            /* Errors ignored. */
            break
          }
        }
      }
    }

    var fmt = v4l2_format()
    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE.rawValue
    if let constraints = constraints {
      fmt.fmt.pix.width = UInt32(constraints.width ?? 0)
      fmt.fmt.pix.height = UInt32(constraints.height ?? 0)
      fmt.fmt.pix.pixelformat = constraints.pixelFormat?.v4l2_pix_fmt ?? 0
      fmt.fmt.pix.field = V4L2_FIELD_ANY.rawValue
      guard -1 != ioctl(self.fileDescriptor, _VIDIOC_S_FMT, &fmt) else {
        throw VideoDeviceError.UnableToWriteFormatToDevice(device:self)
      }
    }
    guard -1 != ioctl(self.fileDescriptor, _VIDIOC_G_FMT, &fmt) else {
      throw VideoDeviceError.UnableToReadFormatFromDevice(device:self)
    }

    var req = v4l2_requestbuffers()
    req.type = V4L2_BUF_TYPE_VIDEO_CAPTURE.rawValue
    req.memory = V4L2_MEMORY_MMAP.rawValue
    req.count = UInt32(numberOfBuffers)
    guard -1 != ioctl(self.fileDescriptor, _VIDIOC_REQBUFS, &req) else {
      throw VideoDeviceError.DeviceIsNotCapableOfMemoryMapping(device:self)
    }

    if Int(req.count) < numberOfBuffers {
      throw VideoDeviceError.UnableToAllocateEnoughBuffers(device:self, numberOfBuffers:numberOfBuffers)
    }

    var buffers: [VideoFrameBuffer] = []
    for i in 0 ..< Int(req.count) {
      var buf = v4l2_buffer()
      buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE.rawValue
      buf.memory = V4L2_MEMORY_MMAP.rawValue
      buf.index = UInt32(i)
      guard -1 != ioctl(self.fileDescriptor, _VIDIOC_QUERYBUF, &buf) else {
        throw VideoDeviceError.UnableToQueryBuffer(device:self)
      }

      guard let baseAddress = mmap(nil,
        Int(buf.length),
        PROT_READ | PROT_WRITE,
        MAP_SHARED,
        self.fileDescriptor,
        __off_t(buf.m.offset)
      ), baseAddress != MAP_FAILED else {
        throw VideoDeviceError.UnableToMapBuffer(device:self)
      }
      buffers.append(VideoFrameBuffer(baseAddress:baseAddress, length:Int(buf.length)))
    }

    return VideoCapture(device:self, buffers:buffers, format:fmt)
  }
}
