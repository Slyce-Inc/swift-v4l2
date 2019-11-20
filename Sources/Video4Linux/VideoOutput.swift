import Clibv4l2
import Foundation

public class VideoOutput {
  public let device: VideoDevice
  let buffers: [VideoFrameBuffer]
  public let frameSizeInBytes:Int

  init(device:VideoDevice, buffers:[VideoFrameBuffer], frameSizeInBytes:Int) {
    self.device = device
    self.buffers = buffers
    self.frameSizeInBytes = frameSizeInBytes
  }

  public func startStreaming() throws {
    for i in 0 ..< buffers.count {
      var buf = v4l2_buffer()
      buf.type = V4L2_BUF_TYPE_VIDEO_OUTPUT.rawValue
      buf.memory = V4L2_MEMORY_MMAP.rawValue
      buf.index = UInt32(i)

      if -1 == ioctl(device.fileDescriptor, _VIDIOC_QBUF, &buf) {
        throw VideoDeviceError.UnableToQueueBuffer(device:device)
      }
    }

    var type = V4L2_BUF_TYPE_VIDEO_OUTPUT.rawValue
    if -1 == ioctl(device.fileDescriptor, _VIDIOC_STREAMON, &type) {
      throw VideoDeviceError.UnableToEnableStreaming(device:device)
    }
  }

  public func write(frame: UnsafeRawPointer) throws {
    Glibc.write(self.device.fileDescriptor, frame, self.frameSizeInBytes)
  }

  public func withFrameBuffer(_ block: (UnsafeMutableRawPointer, Int) -> ()) throws {
    var buf = v4l2_buffer()
    buf.type = V4L2_BUF_TYPE_VIDEO_OUTPUT.rawValue
    buf.memory = V4L2_MEMORY_MMAP.rawValue
    if -1 != ioctl(self.device.fileDescriptor, _VIDIOC_DQBUF, &buf) {
      block(self.buffers[Int(buf.index)].baseAddress, Int(buf.bytesused))
      _ = ioctl(self.device.fileDescriptor, _VIDIOC_QBUF, &buf)
    }
  }

  deinit {
    for buffer in buffers {
      munmap(buffer.baseAddress, buffer.length)
    }
  }
}


public extension VideoDevice {
  func startOutput(width:Int, height:Int, pixelFormat:PixelFormat, numberOfBuffers:Int = 8) throws -> VideoOutput {
    var v = v4l2_format()
    v.type = V4L2_BUF_TYPE_VIDEO_OUTPUT.rawValue
    guard ioctl(self.fileDescriptor, _VIDIOC_G_FMT, &v) != -1 else {
      throw VideoDeviceError.UnableToReadFormatFromDevice(device:self)
    }

    let frameSizeInBytes = pixelFormat.calculateFrameSizeInBytes(width: width, height: height)
    v.fmt.pix.width = UInt32(width)
    v.fmt.pix.height = UInt32(height)
    v.fmt.pix.pixelformat = pixelFormat.v4l2_pix_fmt
    v.fmt.pix.sizeimage = UInt32(frameSizeInBytes)
    guard ioctl(self.fileDescriptor, _VIDIOC_S_FMT, &v) != -1 else {
      throw VideoDeviceError.UnableToWriteFormatToDevice(device:self)
    }

    var req = v4l2_requestbuffers()
    req.type = V4L2_BUF_TYPE_VIDEO_OUTPUT.rawValue
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
      buf.type = V4L2_BUF_TYPE_VIDEO_OUTPUT.rawValue
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

    return VideoOutput(device:self, buffers:buffers, frameSizeInBytes:frameSizeInBytes)
  }
}
