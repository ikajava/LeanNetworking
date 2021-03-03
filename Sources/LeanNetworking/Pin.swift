import Foundation
import CommonCrypto

class Pin: NSObject, URLSessionDelegate {
    
    private let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]
    
    private let pubKey = "55hptqELqWH4rZSXERypbdAv8JGFXoPAfSF+mGvazHg="
    
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                if SecTrustEvaluateWithError(serverTrust, nil) {
                    
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        // Public key pinning
                        let serverPublicKey = SecCertificateCopyKey(serverCertificate)
                        let serverPublicKeyData: NSData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil )!
                        let keyHash = sha256(serverPublicKeyData as Data)
                        if keyHash == pubKey {
                            // Success! This is our server
                            completionHandler(.useCredential, URLCredential(trust: serverTrust))
                            return
                        }
                        
                    }
                }
            }
        }
        
        // Pinning failed
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
    
    func sha256(_ data : Data) -> String {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { ptr in
            _ = CC_SHA256(ptr.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
    
}
