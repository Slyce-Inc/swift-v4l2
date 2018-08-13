import Clibv4l2


extension VideoDevice {
  public enum PixelFormat {
  case RGB24
  case RGB32
  case NV12
  case YU12
  case YUYV
  }
}

extension VideoDevice.PixelFormat {
  var v4l2_pix_fmt: UInt32 {
    switch self {
      case .RGB24: return _V4L2_PIX_FMT_RGB24
      case .RGB32: return _V4L2_PIX_FMT_RGB32
      case .NV12: return _V4L2_PIX_FMT_NV12
      case .YU12: return _V4L2_PIX_FMT_YUV420
      case .YUYV: return _V4L2_PIX_FMT_YUYV
    }
  }

  public func calculateFrameSizeInBytes(width: Int, height: Int) -> Int {
    switch self {
      case .RGB24: return width * height * 3
      case .RGB32: return width * height * 4
      case .NV12: return width * height * 3 / 2
      case .YU12: return width * height * 2
      case .YUYV: return width * height * 2
    }
  }
}
