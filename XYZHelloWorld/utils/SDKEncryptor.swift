//
//  SDKEncryptor.swift
//  nhworld
//
//  Created by Admin on 18/01/23.
//

import Foundation
import SwiftyRSA

// https://github.com/TakeScoop/SwiftyRSA
class SDKEncryptor {
    
    var keyPair : (privateKey: PrivateKey?, publicKey: PublicKey?)
    
    var publicKeyX509: Data?
    
    func initialize() {
        let user = UserDefaults.standard
        do {
            if let privateKey = user.string(forKey: "privatesdkf"), let publicKey = user.string(forKey: "publicsdkf"){
                let publicKey = try PublicKey(base64Encoded: publicKey)
                let privateKey = try PrivateKey(base64Encoded: privateKey)
                keyPair = (privateKey, publicKey)
                print("load key success")
            } else {
                keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 1024)
                saveOnStorage()
                print("generate new key")
            }
        } catch {
            print(error)
        }
    }
    
    func prependX509KeyHeader(keyData: Data) throws -> Data {
        if try keyData.isAnHeaderlessKey() {
            let x509certificate: Data = keyData.prependx509Header()
            print("x509 certificate")
            return x509certificate
        } else if try keyData.hasX509Header() {
            print("x509 header")
            return keyData
        } else { // invalideHeader
            throw SwiftyRSAError.x509CertificateFailed
        }
    }
    
    func saveOnStorage() {
        let user = UserDefaults.standard
        do {
            if let base64 = try keyPair.privateKey?.base64String() {
                print("private key \(String(describing: base64))")
                user.setValue(base64, forKey: "privatesdkf")
            }
            if let base64 = try keyPair.publicKey?.base64String() {
                print("public key \(String(describing: base64))")
                user.setValue(base64, forKey: "publicsdkf")
            }
            if let publicKeyData = try keyPair.publicKey?.data() {
                publicKeyX509 = try prependX509KeyHeader(keyData: publicKeyData)
                let base64 = publicKeyX509?.base64EncodedString()
                print("public key x509 : \(String(describing: base64))")
                user.setValue(base64, forKey: "publicsdkfx509")
            }
            user.setValue(UUID().uuidString, forKey: "ins_id")
        } catch {
            print(error)
        }
    }
    
    func encryptText(message: String) -> String? {
        do {
            let clear = try ClearMessage(string: message, using: .utf8)
            let encrypted = try clear.encrypted(with: keyPair.publicKey!, padding: .PKCS1)
            let data = encrypted.data
            return data.base64EncodedString()
        } catch {
            print(error)
            return nil
        }
    }
    
    func encryptTextX509(message: String) -> String? {
        do {
            let clear = try ClearMessage(string: message, using: .utf8)
            let encrypted = try clear.encrypted(with: keyPair.publicKey!, padding: .PKCS1)
            let data = encrypted.data
            return data.base64EncodedString()
        } catch {
            print("error encrypted x509 message \(error)")
            return nil
        }
    }
    
    // string to byte array encrypt
    private func encryptPart(buffer : [UInt8], mode:Int) -> [UInt8] {
        do{
            let param = Data(bytes: buffer, count: buffer.count)
            let clear = ClearMessage(data:param)
            if (1 == mode) {
                let encrypted = try clear.encrypted(with: keyPair.publicKey!, padding: .PKCS1)
                return [UInt8](encrypted.data)
            }
            if (3 == mode) {
                let user = UserDefaults.standard
                if let pkey = user.string(forKey: "publicsdkfsrv") {
                    let publicKey = try PublicKey(base64Encoded: pkey)
                    let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
                    return [UInt8](encrypted.data)
                } else {
                    print("public srv key not found")
                }
                return []
            }
            return []
        } catch {
            print(error)
            return []
        }
    }
    
    private func encryptPartWithPubKey(buffer : [UInt8], publicKey: PublicKey) -> [UInt8] {
        do{
            let param = Data(bytes: buffer, count: buffer.count)
            let clear = ClearMessage(data:param)
            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
            return [UInt8](encrypted.data)
        } catch {
            print(error)
            return []
        }
    }
    
    // string to byte array decrypt
    private func decryptPart(buffer : [UInt8])->[UInt8] {
        let data = Data(bytes: buffer, count: buffer.count)
        print("decrypte \(data)")
        if let messageSplit = decryptText(message: data.base64EncodedString()) {
            let data = Data(messageSplit.utf8)
            return [UInt8](data)
        }
        print("failed decrypt part");
        return []
    }
    
    func decryptText(message: String) -> String? {
        do {
            let encrypted = try EncryptedMessage(base64Encoded: message)
            let clear = try encrypted.decrypted(with: keyPair.privateKey!, padding: .PKCS1)
            let string = try clear.string(encoding: .utf8)
            return string
        } catch {
            print("error decrypted message \(error)")
            return nil
        }
    }
    
    func encryptTextLong(message: String) -> String? {
        let data = [UInt8](Data(message.utf8)) // string to byte array
        let encryptMessage = blockCipher(bytes: data, mode: 1)
        return Data(encryptMessage).hexEncodedString()
    }
    
    func encryptTextLongServer(message: String) -> String? {
        let data = [UInt8](Data(message.utf8)) // string to byte array
        print("encrypted with pub key server")
        let encryptMessage = blockCipher(bytes: data, mode: 3)
        return Data(encryptMessage).hexEncodedString()
    }
    
    func decryptTextLong(message: String) -> String? {
        let data = Data(fromHex: message)
        let decryptMessageBytes = blockCipher(bytes: [UInt8](data), mode: 2)
        let messageData = Data(decryptMessageBytes)
        let str = String(decoding: messageData, as: UTF8.self)
        return str
    }
    
    /**
     mode 1 = encrypted
     mode 2 = decrypted
     mode 3 = encrypted with server key
     */
    private func blockCipher(bytes: [UInt8], mode:Int) -> [UInt8] {
        let user = UserDefaults.standard
        var publicKey:PublicKey?
        if (mode == 3) {
            if let pkey = user.string(forKey: "publicsdkfsrv") {
                do {
                    publicKey = try PublicKey(base64Encoded: pkey)
                } catch {
                    print(error)
                }
            }
        }
        // string initialize 2 buffers.
        // scrambled will hold intermediate results
        var scrambled: [UInt8] = [UInt8](repeating: 0x00, count: 0)
        // toReturn will hold the total result
        var result : [UInt8] = [UInt8](repeating: 0x00, count: 0)
        // if we encrypt we use 100 byte long blocks. Decryption requires 128 byte long blocks (because of RSA)
        let length : UInt8 = (mode == 1 || mode == 3) ? 100 : 128
        // another buffer. this one will hold the bytes that have to be modified in this step
        var buffer : [UInt8] = [UInt8](repeating: 0x00, count: Int(length))
        for i in 0..<bytes.count {
//            print("byte \(i) from \(bytes.count)")
            // if we filled our buffer array we have our block ready for de- or encryption
            if (i > 0) && (i % Int(length) == 0) {
                // execute the operation
                // add the result to our total result.
                if mode == 1 {
                    scrambled = encryptPart(buffer: buffer, mode: mode)
                } else if mode == 3 {
                    scrambled = encryptPartWithPubKey(buffer: buffer, publicKey: publicKey!)
                } else {
                    scrambled = decryptPart(buffer: buffer)
                }
//                scrambled = (mode == 1 || mode == 3) ? encryptPart(buffer: buffer, mode: mode) : decryptPart(buffer: buffer)
                result = append(result, scrambled)
                // here we calculate the length of the next buffer required
                var newlength : UInt8 = length
                // if newlength would be longer than remaining bytes in the bytes array we shorten it.
                if i + Int(length) > bytes.count {
                    newlength = UInt8(bytes.count - i)
                }
                // clean the buffer array
                buffer = [UInt8](repeating: 0x00, count: Int(newlength))
            }
            // copy byte into our buffer.
            buffer[i % Int(length)] = bytes[Int(i)]
        }
        if mode == 1 {
            scrambled = encryptPart(buffer: buffer, mode: mode)
        } else if mode == 3 {
            scrambled = encryptPartWithPubKey(buffer: buffer, publicKey: publicKey!)
        } else {
            scrambled = decryptPart(buffer: buffer)
        }
        // final step before we can return the modified data.
        result = append(result, scrambled)
        return result
    }
    
    // bytes appender
    private func append(_ prefix : [UInt8], _ suffix : [UInt8]) -> [UInt8] {
        var result: [UInt8] = [UInt8](repeating: 0x00, count: prefix.count + suffix.count)
        for i in 0..<prefix.count {
            result[i] = UInt8(prefix[i])
        }
        for i in 0..<suffix.count {
            result[i + prefix.count] = UInt8(suffix[i])
        }
        return result
    }
    
}
