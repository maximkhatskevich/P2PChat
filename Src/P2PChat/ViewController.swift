//
//  ViewController.swift
//  P2PChat
//
//  Created by Maxim Khatskevich on 12/3/15.
//  Copyright © 2015 Maxim Khatskevich. All rights reserved.
//

import UIKit
import CoreBluetooth

//===

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CBCentralManagerDelegate {
    
    // MARK: Properties - Internal
    
    var manager: CBCentralManager!
    
    var peripherals: [CBPeripheral] = []
    
    // MARK: Properties - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!

    // MARK: Methods - Overrided
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //===
        
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        //===
        
        layout.itemSize.width = UIScreen.mainScreen().bounds.size.width
    }
    
    // MARK: Custom
    
    func update()
    {
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return peripherals.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let result = collectionView
            .dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PeerCell
        
        //===

        let peer = peripherals[indexPath.item]
        result.configure(PeerCellModel(peer: peer))
        
        //===
        
        return result
    }
    
    // MARK: UICollectionViewDelegate

    // MARK: CBCentralManagerDelegate
    
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
    
    func centralManagerDidUpdateState(central: CBCentralManager)
    {
        var msg = "Unknown"
        
        switch central.state
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
        
        if central.state == .PoweredOn
        {
            manager.scanForPeripheralsWithServices(nil, options: nil)
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
            if item.identifier.UUIDString == peripheral.identifier
            {
                shouldAdd = false
                break
            }
        }
        
        if shouldAdd
        {
            peripherals += [peripheral]
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
}

