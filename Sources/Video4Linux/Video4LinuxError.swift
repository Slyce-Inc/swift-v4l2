
public enum VideoDeviceError: Error {
case UnableToOpenDevice(pathToFile:String, message:String)
case UnableToQueryDeviceCapabilities(device:VideoDevice)
case DeviceIsNotCapableOfCapture(device:VideoDevice)
case DeviceIsNotCapableOfStreaming(device:VideoDevice)
case UnableToReadFormatFromDevice(device:VideoDevice)
case UnableToWriteFormatToDevice(device:VideoDevice)
case DeviceIsNotCapableOfMemoryMapping(device:VideoDevice)
case UnableToQueryBuffer(device:VideoDevice)
case UnableToQueueBuffer(device:VideoDevice)
case UnableToEnableStreaming(device:VideoDevice)
case UnableToMapBuffer(device:VideoDevice)
case UnableToAllocateEnoughBuffers(device:VideoDevice, numberOfBuffers:Int)
}
