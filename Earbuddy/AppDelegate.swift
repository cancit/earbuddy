//
//  AppDelegate.swift
//  Pamu Controller
//
//  Created by Can Citoglu on 16.11.2019.
//  Copyright © 2019 Can Citoglu. All rights reserved.
//

import Cocoa
import SwiftUI
import CoreBluetooth
import IOBluetoothUI
// 55580C71-7DCE-4042-83A2-518DCC1CDBEB
// 257D86B9-5731-416E-9E98-C1B4E5165199
// 87A139C6-1E56-406D-87F4-6F898C426E12
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, BluetoothConnectionDelegate {


    static let FORCE_OUTPUT_KEY = "forceOutputEnabled"
    static var window: NSWindow!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var statusBarMenu: NSMenu?
    var forceOutputItem: NSMenuItem?
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        setupMenu()
        setupNotifications()

        BluetoothController.shared.setDelegate(delegate: self)
        BluetoothController.shared.start()
    }
    func setupMenu() {
        statusBarMenu = NSMenu(title: "")
        statusBarMenu?.minimumWidth = 200
        // statusBarMenu.action
        let forceOutputEnabled = UserDefaults().bool(forKey: AppDelegate.FORCE_OUTPUT_KEY)
        statusBarMenu!.addItem(
            withTitle: "Connect",
            action: nil,
            keyEquivalent: "")
        statusBarMenu?.addItem(NSMenuItem.separator())
        statusBarMenu!.addItem(
            withTitle: "Not Connected",
            action: #selector(toggleConnect(_:)),
            keyEquivalent: "")
        statusBarMenu!.addItem(
            withTitle: "Reconnect",
            action: nil,
            keyEquivalent: "")
        statusBarMenu?.addItem(NSMenuItem.separator())
        forceOutputItem = NSMenuItem(
            title: "Force as output",
        action: #selector(toggleForAsOutput(_:)),
            keyEquivalent: "")
        forceOutputItem!.state = forceOutputEnabled ? .on : .off
        statusBarMenu!.addItem(forceOutputItem!)
        statusBarMenu!.addItem(
            withTitle: "Settings",
            action: #selector(openSettings(_:)),
            keyEquivalent: "")
        statusBarMenu!.addItem(
            withTitle: "Quit",
            action: #selector(quit(_:)),
            keyEquivalent: "")

        statusItem.menu = statusBarMenu
    }
    
    @objc func toggleForAsOutput(_ sender: Any?) {
        let forceOutputEnabled = !UserDefaults().bool(forKey: AppDelegate.FORCE_OUTPUT_KEY)
        forceOutputItem!.state = forceOutputEnabled ? .on : .off
        UserDefaults().set(forceOutputEnabled, forKey: AppDelegate.FORCE_OUTPUT_KEY)
    }
    @objc func openSettings(_ sender: Any?) {
      //  IOBluetoothDeviceSelectorController.deviceSelector().showWindow(nil)
        let contentView = ContentView()

        // Create the window and set the content view.
        AppDelegate.window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: true)
        AppDelegate.window.center()
        AppDelegate.window.setFrameAutosaveName("Settings")
        AppDelegate.window.contentView = NSHostingView(rootView: contentView)
        AppDelegate.window.makeKeyAndOrderFront(true)
        AppDelegate.window.isReleasedWhenClosed = false
    }
    @objc func quit(_ sender: Any?) {
        NSApp.terminate(nil)
    }
    var checkTimer: Timer?;
    func onConnected() {
        DispatchQueue.main.async {

            self.renderConnectedState()
        }
        //   checkTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(("checkDevices")), userInfo: nil, repeats: true)

    }

    func onDisconnected() {
        DispatchQueue.main.async {
            self.renderDisconnectedState()
        }
    }
    func renderConnectedState() {
        let deviceName = BluetoothController.shared.bluetoothDevice?.name ?? "Device"

        statusItem.button!.image = NSImage(named: NSImage.Name("pod-enabled"))
        statusItem.button!.toolTip = "\(deviceName) Connected"
        statusItem.menu!.items[0].title = "\(deviceName) Connected"
        statusItem.menu!.items[2].title = "Disconnect"
        statusItem.menu!.items[3].action = #selector(reconnect(_:))
        statusItem.menu!.items[3].isEnabled = true


    }
    func renderDisconnectedState() {
        statusItem.button!.image = NSImage(named: NSImage.Name("pod-disabled"))
        statusItem.button!.toolTip = "No Connection"
        statusItem.menu!.items[0].title = "Not Connected"
        statusItem.menu!.items[2].title = "Connect"
        statusItem.menu!.items[3].isEnabled = false



    }

    @objc func reconnect(_ sender: Any?) {
        BluetoothController.shared.disconnectAndConnectAgain()
    }
    @objc func toggleConnect(_ sender: Any?) {
        //  if(MPNowPlayingInfoCenter.default().playbackState == .){
        if(BluetoothController.shared.bluetoothDevice!.isConnected()) {
            //  renderDisconnectedState()
            BluetoothController.shared.disconnect()
            mute()
        } else {
            // renderConnectedState()
            BluetoothController.shared.reconnect()
            mute()
        }
    }


    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

