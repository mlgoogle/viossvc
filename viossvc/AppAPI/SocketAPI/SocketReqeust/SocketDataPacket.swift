//
//  SocketDataPacket.swift
//  viossvc
//
//  Created by yaowang on 2016/11/22.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import UIKit
import XCGLogger
class SocketDataPacket {
    
    enum PacketType: Int8 {
        case Error = 0
        case User = 1
        case Chat = 2
    }
    
    var packetHead:SocketPacketHead = SocketPacketHead();
    var data: NSData?
    private static var packet_id:UInt32 = 10000;
    var packet_length:UInt16 {
        get { return packetHead.packet_length }
        set { packetHead.packet_length = newValue }
    }
    var is_zip_encrypt:UInt8  {
        get { return packetHead.is_zip_encrypt }
        set { packetHead.is_zip_encrypt = newValue }
    }

    var type:UInt8 {
        get { return packetHead.type }
        set { packetHead.type = newValue }
    }
    var signature:UInt16 {
        get { return packetHead.signature }
        set { packetHead.signature = newValue }
    }

    var operate_code:UInt16 {
        get { return packetHead.operate_code }
        set { packetHead.operate_code = newValue }
    }

    var data_length:UInt16 {
        get { return packetHead.data_length }
        set { packetHead.data_length = newValue }
    }


    var timestamp:UInt32 {
        get { return packetHead.timestamp }
        set { packetHead.timestamp = newValue }
    }


    var session_id:UInt64 {
        get { return packetHead.session_id }
        set { packetHead.session_id = newValue }
    }

    var request_id:UInt32 {
        get { return packetHead.request_id }
        set { packetHead.request_id = newValue }
    }



    init() {
        memset(&self.packetHead,0, sizeof(SocketPacketHead))
    }
    convenience init(opcode: SocketConst.OPCode,type: SocketConst.type = .User) {
        self.init(opcode: opcode,data:nil,type: type);
    }
    convenience init(opcode: SocketConst.OPCode, data: NSData?,type: SocketConst.type = .User) {
        self.init();
        self.type = type.rawValue
        self.operate_code = opcode.rawValue
        self.data = data
        self.data_length = data == nil ? 0 : UInt16(data!.length)
        self.packet_length = self.data_length + 0x1a
        self.timestamp = UInt32(NSDate().timeIntervalSince1970)
    }

    convenience init( opcode: SocketConst.OPCode, strData: String,type: SocketConst.type = .User) {
        let data: NSData! = strData.dataUsingEncoding(NSUTF8StringEncoding)
        self.init( opcode: opcode, data: data,type: type)
    }

    convenience init(opcode: SocketConst.OPCode, model: BaseModel,type: SocketConst.type = .User) {
        let strData: String = model.description
        self.init( opcode: opcode, strData: strData,type:type)
    }
    
    convenience init(opcode: SocketConst.OPCode, dict:[String : AnyObject],type: SocketConst.type = .User) {
        let data = try? NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
        self.init( opcode: opcode, data: data,type: type)
    }
    
    init(socketData:NSData) {
        memset(&packetHead,0, sizeof(SocketPacketHead))
        socketData.getBytes(&packetHead, length: sizeof(SocketPacketHead))
        var range:NSRange = NSMakeRange(0,Int(data_length))
        range.location = Int(packet_length - data_length)
        self.data = socketData.subdataWithRange(range)
    }
    

    func serializableData() -> NSData? {
        let outdata: NSMutableData = NSMutableData()
//        self.data_length = data == nil ? 0 : UInt16(data!.length)
//        self.packet_length = self.data_length + 0x1a
//        self.timestamp = UInt32(NSDate().timeIntervalSince1970)
        outdata.appendBytes(&self.packetHead, length: sizeof(SocketPacketHead));
        if self.data != nil {
            outdata.appendData(self.data!)
        }
        return outdata;
    }

    func bodyDictionary() -> NSDictionary {
        return try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary;
    }
    
//    deinit {
//            XCGLogger.debug("deinit \(self)")
//    }
}
