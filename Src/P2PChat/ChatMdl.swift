//
//  ChatMdl.swift
//  P2PChat
//
//  Created by Maxim Khatskevich on 12/6/15.
//  Copyright © 2015 Maxim Khatskevich. All rights reserved.
//

import UIKit
import CoreBluetooth

//===

class ChatMdl: NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate
{
    // MARK: Properties - Private
    
    private var cMgr: CBCentralManager!
    private var pMgr: CBPeripheralManager!
    
    private var peers: [String: ConversationMdl] = [:]
    
    // MARK: Properties - Public
    
    let serviceID = CBUUID(string: "C7B8B56C-999B-43E7-AF0B-4920BC36DF81")
    
    //===
    
    var lastUpdated = NSDate() // observe this to know when reload list
    
    var conversations: [ConversationMdl] {
        
        get {
            
            var result: [ConversationMdl] = []
            
            //===
            
            for (_, value) in peers
            {
                result.append(value)
            }
            
            //===
            
            return result // TODO: sort here
        }
    }
    
    // MARK: Methods - Generic
    
    func activate()
    {
        cMgr = CBCentralManager(delegate: self, queue: nil)
        
        //===
        
        pMgr = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    // MARK: Methods - CBCentralManagerDelegate
    
    /*!
    *  @method centralManagerDidUpdateState:
    *
    *  @param central  The central manager whose state has changed.
    *
    *  @discussion     Invoked whenever the central manager's state has been updated. Commands should only be issued when the state is
    *                  <code>CBCentralManagerStatePoweredOn</code>. A state below <code>CBCentralManagerStatePoweredOn</code>
    *                  implies that scanning has stopped and any connected peripherals have been disconnected. If the state moves below
    *                  <code>CBCentralManagerStatePoweredOff</code>, all <code>CBPeripheral</code> objects obtained from this central
    *                  manager become invalid and must be retrieved or discovered again.
    *
    *  @see            state
    *
    */
    
    func centralManagerDidUpdateState(centralMgr: CBCentralManager)
    {
        var msg = "Unknown"
        
        switch centralMgr.state
        {
        case .Resetting:
            msg = "Resetting"
            
        case .Unsupported:
            msg = "Unsupported"
            
        case .Unauthorized:
            msg = "Unauthorized"
            
        case .PoweredOff:
            msg = "PoweredOff"
            
        case .PoweredOn:
            msg = "PoweredOn"
            
        default:
            break;
        }
        
        print("DidUpdateState \(msg)")
        
        //===
        
        if centralMgr.state == .PoweredOn
        {
            // http://stackoverflow.com/a/18078828
            // affects battery life
            
            let scanOptions = [CBCentralManagerScanOptionAllowDuplicatesKey: true]
            
            centralMgr.scanForPeripheralsWithServices([chat.serviceID], options: scanOptions)
        }
    }
    
    /*!
    *  @method centralManager:willRestoreState:
    *
    *  @param central      The central manager providing this information.
    *  @param dict			A dictionary containing information about <i>central</i> that was preserved by the system at the time the app was terminated.
    *
    *  @discussion			For apps that opt-in to state preservation and restoration, this is the first method invoked when your app is relaunched into
    *						the background to complete some Bluetooth-related task. Use this method to synchronize your app's state with the state of the
    *						Bluetooth system.
    *
    *  @seealso            CBCentralManagerRestoredStatePeripheralsKey;
    *  @seealso            CBCentralManagerRestoredStateScanServicesKey;
    *  @seealso            CBCentralManagerRestoredStateScanOptionsKey;
    *
    */
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject])
    {
        print("willRestoreState \(dict)")
    }
    
    /*!
    *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI:
    *
    *  @param central              The central manager providing this update.
    *  @param peripheral           A <code>CBPeripheral</code> object.
    *  @param advertisementData    A dictionary containing any advertisement and scan response data.
    *  @param RSSI                 The current RSSI of <i>peripheral</i>, in dBm. A value of <code>127</code> is reserved and indicates the RSSI
    *								was not available.
    *
    *  @discussion                 This method is invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>. A discovered peripheral must
    *                              be retained in order to use it; otherwise, it is assumed to not be of interest and will be cleaned up by the central manager. For
    *                              a list of <i>advertisementData</i> keys, see {@link CBAdvertisementDataLocalNameKey} and other similar constants.
    *
    *  @seealso                    CBAdvertisementData.h
    *
    */
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber)
    {
        print("didDiscoverPeripheral \(peripheral), data \(advertisementData), RSSI \(RSSI)")
        
        //===
        
        var shouldAdd = true

        for item in peripherals
        {
            if item.identifier.UUIDString == peripheral.identifier.UUIDString
            {
                shouldAdd = false
                break
            }
        }

        if shouldAdd
        {
            peripherals += [peripheral]

            print("===== peripherals: \(peripherals)")

            update()
        }
    }
    
    /*!
    *  @method centralManager:didConnectPeripheral:
    *
    *  @param central      The central manager providing this information.
    *  @param peripheral   The <code>CBPeripheral</code> that has connected.
    *
    *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has succeeded.
    *
    */
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral)
    {
        print("didConnectPeripheral \(peripheral)")
    }
    
    /*!
    *  @method centralManager:didFailToConnectPeripheral:error:
    *
    *  @param central      The central manager providing this information.
    *  @param peripheral   The <code>CBPeripheral</code> that has failed to connect.
    *  @param error        The cause of the failure.
    *
    *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has failed to complete. As connection attempts do not
    *                      timeout, the failure of a connection is atypical and usually indicative of a transient issue.
    *
    */
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?)
    {
        print("didFailToConnectPeripheral \(peripheral), error \(error)")
    }
    
    /*!
    *  @method centralManager:didDisconnectPeripheral:error:
    *
    *  @param central      The central manager providing this information.
    *  @param peripheral   The <code>CBPeripheral</code> that has disconnected.
    *  @param error        If an error occurred, the cause of the failure.
    *
    *  @discussion         This method is invoked upon the disconnection of a peripheral that was connected by {@link connectPeripheral:options:}. If the disconnection
    *                      was not initiated by {@link cancelPeripheralConnection}, the cause will be detailed in the <i>error</i> parameter. Once this method has been
    *                      called, no more methods will be invoked on <i>peripheral</i>'s <code>CBPeripheralDelegate</code>.
    *
    */
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?)
    {
        print("didDisconnectPeripheral \(peripheral), error \(error)")
    }
    
    // MARK: Methods - CBPeripheralManagerDelegate
    
    /*!
    *  @method peripheralManagerDidUpdateState:
    *
    *  @param peripheral   The peripheral manager whose state has changed.
    *
    *  @discussion         Invoked whenever the peripheral manager's state has been updated. Commands should only be issued when the state is
    *                      <code>CBPeripheralManagerStatePoweredOn</code>. A state below <code>CBPeripheralManagerStatePoweredOn</code>
    *                      implies that advertisement has paused and any connected centrals have been disconnected. If the state moves below
    *                      <code>CBPeripheralManagerStatePoweredOff</code>, advertisement is stopped and must be explicitly restarted, and the
    *                      local database is cleared and all services must be re-added.
    *
    *  @see                state
    *
    */
    func peripheralManagerDidUpdateState(peripheralMgr: CBPeripheralManager)
    {
        var msg = "Unknown"
        
        switch peripheralMgr.state
        {
        case .Resetting:
            msg = "Resetting"
            
        case .Unsupported:
            msg = "Unsupported"
            
        case .Unauthorized:
            msg = "Unauthorized"
            
        case .PoweredOff:
            msg = "PoweredOff"
            
        case .PoweredOn:
            msg = "PoweredOn"
            
        default:
            break;
        }
        
        print("DidUpdateState \(msg)")
        
        //===
        
        if peripheralMgr.state == .PoweredOn
        {
            let inputCharacteristic = CBMutableCharacteristic(type: chat.serviceID,
                properties: .Write, value: nil, permissions: .Writeable)
            
            let outputCharacteristic = CBMutableCharacteristic(type: chat.serviceID,
                properties: .Read, value: nil, permissions: .Readable)
            
            let service = CBMutableService(type: chat.serviceID, primary: true)
            service.characteristics = [inputCharacteristic, outputCharacteristic]
            
            peripheralMgr.addService(service)
            
            peripheralMgr.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [service.UUID],
                CBAdvertisementDataLocalNameKey: "P2P-BLE-Chat"])
        }
    }
    
    /*!
    *  @method peripheralManager:willRestoreState:
    *
    *  @param peripheral	The peripheral manager providing this information.
    *  @param dict			A dictionary containing information about <i>peripheral</i> that was preserved by the system at the time the app was terminated.
    *
    *  @discussion			For apps that opt-in to state preservation and restoration, this is the first method invoked when your app is relaunched into
    *						the background to complete some Bluetooth-related task. Use this method to synchronize your app's state with the state of the
    *						Bluetooth system.
    *
    *  @seealso            CBPeripheralManagerRestoredStateServicesKey;
    *  @seealso            CBPeripheralManagerRestoredStateAdvertisementDataKey;
    *
    */
    func peripheralManager(peripheral: CBPeripheralManager, willRestoreState dict: [String : AnyObject])
    {
        //
    }
    
    /*!
    *  @method peripheralManagerDidStartAdvertising:error:
    *
    *  @param peripheral   The peripheral manager providing this information.
    *  @param error        If an error occurred, the cause of the failure.
    *
    *  @discussion         This method returns the result of a @link startAdvertising: @/link call. If advertisement could
    *                      not be started, the cause will be detailed in the <i>error</i> parameter.
    *
    */
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?)
    {
        if let er = error
        {
            print("didAddService failed: \(er)")
        }
    }
    
    /*!
    *  @method peripheralManager:didAddService:error:
    *
    *  @param peripheral   The peripheral manager providing this information.
    *  @param service      The service that was added to the local database.
    *  @param error        If an error occurred, the cause of the failure.
    *
    *  @discussion         This method returns the result of an @link addService: @/link call. If the service could
    *                      not be published to the local database, the cause will be detailed in the <i>error</i> parameter.
    *
    */
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?)
    {
        if let er = error
        {
            print("didAddService failed: \(er)")
        }
    }
    
    /*!
    *  @method peripheralManager:central:didSubscribeToCharacteristic:
    *
    *  @param peripheral       The peripheral manager providing this update.
    *  @param central          The central that issued the command.
    *  @param characteristic   The characteristic on which notifications or indications were enabled.
    *
    *  @discussion             This method is invoked when a central configures <i>characteristic</i> to notify or indicate.
    *                          It should be used as a cue to start sending updates as the characteristic value changes.
    *
    */
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic)
    {
        //
    }
    
    /*!
    *  @method peripheralManager:central:didUnsubscribeFromCharacteristic:
    *
    *  @param peripheral       The peripheral manager providing this update.
    *  @param central          The central that issued the command.
    *  @param characteristic   The characteristic on which notifications or indications were disabled.
    *
    *  @discussion             This method is invoked when a central removes notifications/indications from <i>characteristic</i>.
    *
    */
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic)
    {
        //
    }
    
    /*!
    *  @method peripheralManager:didReceiveReadRequest:
    *
    *  @param peripheral   The peripheral manager requesting this information.
    *  @param request      A <code>CBATTRequest</code> object.
    *
    *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request for a characteristic with a dynamic value.
    *                      For every invocation of this method, @link respondToRequest:withResult: @/link must be called.
    *
    *  @see                CBATTRequest
    *
    */
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest)
    {
        //
    }
    
    /*!
    *  @method peripheralManager:didReceiveWriteRequests:
    *
    *  @param peripheral   The peripheral manager requesting this information.
    *  @param requests     A list of one or more <code>CBATTRequest</code> objects.
    *
    *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request or command for one or more characteristics with a dynamic value.
    *                      For every invocation of this method, @link respondToRequest:withResult: @/link should be called exactly once. If <i>requests</i> contains
    *                      multiple requests, they must be treated as an atomic unit. If the execution of one of the requests would cause a failure, the request
    *                      and error reason should be provided to <code>respondToRequest:withResult:</code> and none of the requests should be executed.
    *
    *  @see                CBATTRequest
    *
    */
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest])
    {
        //
    }
    
    /*!
    *  @method peripheralManagerIsReadyToUpdateSubscribers:
    *
    *  @param peripheral   The peripheral manager providing this update.
    *
    *  @discussion         This method is invoked after a failed call to @link updateValue:forCharacteristic:onSubscribedCentrals: @/link, when <i>peripheral</i> is again
    *                      ready to send characteristic value updates.
    *
    */
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager)
    {
        //
    }
}
