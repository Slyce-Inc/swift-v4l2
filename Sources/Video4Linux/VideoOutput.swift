import Clibv4l2
import Foundation

public class VideoOutput {
  public let device: VideoDevice
  let buffers: [VideoFrameBuffer]

  init(device:VideoDevice, buffers:[VideoFrameBuffer]) {
    self.device = device
    self.buffers = buffers
  }

  deinit {
    for buffer in buffers {
      munmap(buffer.baseAddress, buffer.length)
    }
  }
}


public extension VideoDevice {
  public func startOutput(width:Int, height:Int, pixelFormat:PixelFormat) throws -> VideoOutput {
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

    return VideoOutput(device:self, buffers:[])
  }
}
