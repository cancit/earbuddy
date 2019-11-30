//
//  Util.swift
//  Pamu Controller
//
//  Created by Can Citoglu on 16.11.2019.
//  Copyright © 2019 Can Citoglu. All rights reserved.
//

import Foundation
import Cocoa
import MediaPlayer
import AudioToolbox

func convertIOReturnToString(_ status: IOReturn) -> String? {
    let map = [
        kIOReturnSuccess: "success",
        kIOReturnError: "general error",
        kIOReturnNoMemory: "memory allocation error",
        kIOReturnNoResources: "resource shortage",
        kIOReturnIPCError: "Mach IPC failure",
        kIOReturnNoDevice: "no such device",
        kIOReturnNotPrivileged: "privilege violation",
        kIOReturnBadArgument: "invalid argument",
        kIOReturnLockedRead: "device is read locked",
        kIOReturnLockedWrite: "device is write locked",
        kIOReturnExclusiveAccess: "device is exclusive access",
        kIOReturnBadMessageID: "bad IPC message ID",
        kIOReturnUnsupported: "unsupported function",
        kIOReturnVMError: "virtual memory error",
        kIOReturnInternalError: "internal driver error",
        kIOReturnIOError: "I/O error",
        kIOReturnCannotLock: "cannot acquire lock",
        kIOReturnNotOpen: "device is not open",
        kIOReturnNotReadable: "device is not readable",
        kIOReturnNotWritable: "device is not writeable",
        kIOReturnNotAligned: "alignment error",
        kIOReturnBadMedia: "media error",
        kIOReturnStillOpen: "device is still open",
        kIOReturnRLDError: "rld failure",
        kIOReturnDMAError: "DMA failure",
        kIOReturnBusy: "device is busy",
        kIOReturnTimeout: "I/O timeout",
        kIOReturnOffline: "device is offline",
        kIOReturnNotReady: "device is not ready",
        kIOReturnNotAttached: "device/channel is not attached",
        kIOReturnNoChannels: "no DMA channels available",
        kIOReturnNoSpace: "no space for data",
        kIOReturnPortExists: "device port already exists",
        kIOReturnCannotWire: "cannot wire physical memory",
        kIOReturnNoInterrupt: "no interrupt attached",
        kIOReturnNoFrames: "no DMA frames enqueued",
        kIOReturnMessageTooLarge: "message is too large",
        kIOReturnNotPermitted: "operation is not permitted",
        kIOReturnNoPower: "device is without power",
        kIOReturnNoMedia: "media is not present",
        kIOReturnUnformattedMedia: "media is not formatted",
        kIOReturnUnsupportedMode: "unsupported mode",
        kIOReturnUnderrun: "data underrun",
        kIOReturnOverrun: "data overrun",
        kIOReturnDeviceError: "device error",
        kIOReturnNoCompletion: "no completion routine",
        kIOReturnAborted: "operation was aborted",
        kIOReturnNoBandwidth: "bus bandwidth would be exceeded",
        kIOReturnNotResponding: "device is not responding",
        kIOReturnInvalid: "unanticipated driver error"
    ]

    return map[status]
}

@discardableResult func executeAppleScript(source: String) -> String {
  let process = Process()
  process.launchPath = "/usr/bin/osascript"
  process.arguments = [String(format: "-e %@", source)]
  
  let pipe = Pipe()
  process.standardOutput = pipe
  process.launch()
  
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  guard let output = String(data: data, encoding: .utf8) else {
    return ""
  }
  
  return output.trimmingCharacters(in: .whitespacesAndNewlines)
}
func isMuted() -> Bool {
  return executeAppleScript(source: "output muted of (get volume settings)") == "true"
}

let NX_KEYTYPE_SOUND_UP: UInt32 = 0
      let NX_KEYTYPE_SOUND_DOWN: UInt32 = 1
      let NX_KEYTYPE_MUTE: UInt32 = 7
      let NX_KEYTYPE_PLAY: UInt32 = 16
      let NX_KEYTYPE_NEXT: UInt32 = 17
      let NX_KEYTYPE_PREVIOUS: UInt32 = 18
      let NX_KEYTYPE_FAST: UInt32 = 19
      let NX_KEYTYPE_REWIND: UInt32 = 20
  
      func HIDPostAuxKey(key: UInt32) {
          func doKey(down: Bool) {
              let flags = NSEvent.ModifierFlags(rawValue: (down ? 0xa00 : 0xb00))
              let data1 = Int((key<<16) | (down ? 0xa00 : 0xb00))

              let ev = NSEvent.otherEvent(with: NSEvent.EventType.systemDefined,
                                          location: NSPoint(x:0,y:0),
                                          modifierFlags: flags,
                                          timestamp: 0,
                                          windowNumber: 0,
                                          context: nil,
                                          subtype: 8,
                                          data1: data1,
                                          data2: -1
                                          )
              let cev = ev?.cgEvent
              cev?.post(tap: CGEventTapLocation.cghidEventTap)
          }
          doKey(down: true)
          doKey(down: false)
      }
func mute() {
  executeAppleScript(source: "set volume with output muted")
}

func unmute() {
  executeAppleScript(source: "set volume without output muted")
}
func getVolume(){
      var defaultOutputDeviceID = AudioDeviceID(0)
      var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))

      var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
          mSelector: kAudioHardwarePropertyDefaultOutputDevice,
          mScope: kAudioObjectPropertyScopeGlobal,
          mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

      let status1 = AudioObjectGetPropertyData(
          AudioObjectID(kAudioObjectSystemObject),
          &getDefaultOutputDevicePropertyAddress,
          0,
          nil,
          &defaultOutputDeviceIDSize,
          &defaultOutputDeviceID)
      
      var volume = Float32(0.0)
      var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))

      var volumePropertyAddress = AudioObjectPropertyAddress(
          mSelector: kAudioHardwareServiceDeviceProperty_VirtualMasterVolume,
          mScope: kAudioDevicePropertyScopeOutput,
          mElement: kAudioObjectPropertyElementMaster)

      let status3 = AudioObjectGetPropertyData(
          defaultOutputDeviceID,
          &volumePropertyAddress,
          0,
          nil,
          &volumeSize,
          &volume)

      print(volume)
  }
func getOutputDevices() -> [AudioDeviceID: String]? {
    var result: [AudioDeviceID: String] = [:]
    let devices = getAllDevices()
    
    for device in devices {
        if isOutputDevice(deviceID: device) {
            result[device] = getDeviceName(deviceID: device)
        }
    }
    
    return result
}
 func getDeviceName(deviceID: AudioDeviceID) -> String {
      var propertySize = UInt32(MemoryLayout<CFString>.size)
      
      var propertyAddress = AudioObjectPropertyAddress(
          mSelector: AudioObjectPropertySelector(kAudioDevicePropertyDeviceNameCFString),
          mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
          mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
      
      var result: CFString = "" as CFString
      
      AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &result)
      
      return result as String
  }
func isOutputDevice(deviceID: AudioDeviceID) -> Bool {
    var propertySize: UInt32 = 256
    
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: AudioObjectPropertySelector(kAudioDevicePropertyStreams),
        mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
        mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
    
    _ = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, nil, &propertySize)
    
    return propertySize > 0
}
func getAllDevices() -> [AudioDeviceID] {
     let devicesCount = getNumberOfDevices()
     var devices = [AudioDeviceID](repeating: 0, count: Int(devicesCount))
     
     var propertyAddress = AudioObjectPropertyAddress(
         mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
         mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
         mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
     
     var devicesSize = devicesCount * UInt32(MemoryLayout<UInt32>.size)
     
     AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &devicesSize, &devices)
     
     return devices
 }

func getNumberOfDevices() -> UInt32 {
    var propertySize: UInt32 = 0
    
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
        mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
        mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
    
    _ = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize)
    
    return propertySize / UInt32(MemoryLayout<AudioDeviceID>.size)
}
func listenOutputDevices(){
    print("is that a change?!?!")
}

func setupNotifications() {
  
    addListenerBlock(listenerBlock: audioObjectPropertyListenerBlock,
                     onAudioObjectID: AudioObjectID(bitPattern: kAudioObjectSystemObject)
          )
}

func addListenerBlock( listenerBlock: AudioObjectPropertyListenerBlock, onAudioObjectID: AudioObjectID) {
    var propertyAddress =  AudioObjectPropertyAddress(
                 mSelector: kAudioHardwarePropertyDefaultOutputDevice,
                 mScope: kAudioObjectPropertyScopeGlobal,
                 mElement: kAudioObjectPropertyElementMaster)
    if (kAudioHardwareNoError != AudioObjectAddPropertyListenerBlock(onAudioObjectID, &propertyAddress, nil, audioObjectPropertyListenerBlock)) {
        print("Error calling: AudioObjectAddPropertyListenerBlock") }
 }

 func audioObjectPropertyListenerBlock (numberAddresses: UInt32, addresses: UnsafePointer<AudioObjectPropertyAddress>) {

      var index: Int = 0
      while index < numberAddresses {
          let address: AudioObjectPropertyAddress = addresses[index]
          switch address.mSelector {
          case kAudioHardwarePropertyDefaultOutputDevice:

              let deviceID = getDefaultAudioOutputDevice()
              print("kAudioHardwarePropertyDefaultOutputDevice: \(deviceID)")
              let outputName = getDeviceName(deviceID: deviceID)
              if(outputName != BluetoothController.shared.bluetoothDevice?.name){
                print("connection lost!")
                if(UserDefaults().bool(forKey: AppDelegate.FORCE_OUTPUT_KEY)){
                    mute()
                    BluetoothController.shared.fixSourceDisableBug()
                }
            }
            //  print(getOutputDevices()[deviceID])
          default:

              print("We didn't expect this!")

          }
          index += 1
     }
}
     // Utility function to get default audio output device:
     func getDefaultAudioOutputDevice () -> AudioObjectID {

         var devicePropertyAddress = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDefaultOutputDevice, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)
         var deviceID: AudioObjectID = 0
        var dataSize = UInt32(MemoryLayout<UInt32>.size)
         let systemObjectID = AudioObjectID(bitPattern: kAudioObjectSystemObject)
         if (kAudioHardwareNoError != AudioObjectGetPropertyData(systemObjectID, &devicePropertyAddress, 0, nil, &dataSize, &deviceID)) { return 0 }
         return deviceID
     }


