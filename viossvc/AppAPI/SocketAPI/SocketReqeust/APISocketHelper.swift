//
//  APISocketHelper.swift
//  viossvc
//
//  Created by yaowang on 2016/11/21.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import XCGLogger
import SVProgressHUD
class APISocketHelper:NSObject, GCDAsyncSocketDelegate {
    var socket: GCDAsyncSocket?;
    var dispatch_queue: dispatch_queue_t!;
    var mutableData: NSMutableData = NSMutableData();

    var disconnected = false
    
    var isConnected : Bool {
        return socket!.isConnected
    }
    override init() {
        super.init()
        dispatch_queue = dispatch_queue_create("APISocket_Queue", DISPATCH_QUEUE_CONCURRENT)
        socket = GCDAsyncSocket.init(delegate: self, delegateQueue: dispatch_queue);
//        connect()
    }

    func connect() {
        mutableData = NSMutableData()
        do {
            if !socket!.isConnected {
                try socket?.connectToHost(AppConst.Network.TcpServerIP, onPort: AppConst.Network.TcpServerPort, withTimeout: 5)
            }
        } catch GCDAsyncSocketError.ClosedError {

        } catch GCDAsyncSocketError.ConnectTimeoutError {

        } catch {

        }
    }
    
    func disconnect() {
//        socket?.delegate = nil;
        socket?.disconnect()
    }
    
    func sendData(data: NSData) {
        objc_sync_enter(self)
        socket?.writeData(data, withTimeout: -1, tag: 0)
        objc_sync_exit(self)
    }


    func onPacketData(data: NSData) {
        let packet: SocketDataPacket = SocketDataPacket(socketData: data)
        SocketRequestManage.shared.notifyResponsePacket(packet)
        XCGLogger.debug("onPacketData:\(packet.packetHead.type) \(packet.packetHead.packet_length) \(packet.packetHead.operate_code)")
    }

    //MARK: GCDAsyncSocketDelegate
    @objc func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        XCGLogger.debug("didConnectToHost:\(host)  \(port)")
        sock.performBlock({
            () -> Void in
            sock.enableBackgroundingOnSocket()
        });
        socket?.readDataWithTimeout(-1, tag: 0)
    }
    
    func relogin() {
        if disconnected {
            disconnected = false
            if  CurrentUserHelper.shared.autoLogin({ (model) in
                SVProgressHUD.dismiss()
                }, error: { [weak self] (error) in
                    SVProgressHUD.showErrorWithStatus(error.localizedDescription)
                    XCGLogger.error("\(error) \(self)")
                    
                }) {
                SVProgressHUD.showWithStatus("登录中...")
            }
        }
    }

    @objc func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: CLong) {
//        XCGLogger.debug("socket:\(data)")
        mutableData.appendData(data)
        while mutableData.length > 2 {
            var packetLen: Int16 = 0;
            mutableData.getBytes(&packetLen, length: sizeof(Int16))
            if mutableData.length >= Int(packetLen) {
                var range: NSRange = NSMakeRange(0, Int(packetLen))
                onPacketData(mutableData.subdataWithRange(range))
                range.location = range.length;
                range.length = mutableData.length - range.location;
                mutableData = mutableData.subdataWithRange(range).mutableCopy() as! NSMutableData;
            } else {
                break
            }
        }
        socket?.readDataWithTimeout(-1, tag: 0)
        
    }

    @objc func socket(sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: CLong, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        return 0
    }

    @objc func socket(sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: CLong, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        return 0
    }

    @objc func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError?) {
        XCGLogger.error("socketDidDisconnect:\(err)")
        self.performSelector(#selector(connect), withObject: nil, afterDelay: 5)
//        SVProgressHUD.showErrorMessage(ErrorMessage: "连接失败，5秒后重连", ForDuration: 5) {[weak self] in
//            self?.connect()
//        }
        disconnected = true
    }

    deinit {
        socket?.disconnect()
    }
}
