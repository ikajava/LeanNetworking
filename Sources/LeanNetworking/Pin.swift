import Foundation
import CommonCrypto

class SessionDelegate : NSObject, URLSessionDelegate {
    
    private static let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ];
    
    private static let google_com_pubkey = ["47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU="];
    private static let google_com_full = ["KEMk92zeeRAUvSFH9wiY3T9oaTGOjfsXG1z/z+vooBo="];
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil);
            return;
        }
        
        // Set SSL policies for domain name check
        let policies = NSMutableArray();
        policies.add(SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString)));
        SecTrustSetPolicies(serverTrust, policies);
        
        var isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil);
        
        if(isServerTrusted && challenge.protectionSpace.host == "staging-723489234y.albums.app") {
            let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
            //Compare public key
            if #available(iOS 10.0, *) {
                let policy = SecPolicyCreateBasicX509();
                let cfCertificates = [certificate] as CFArray;
                
                var trust: SecTrust?
                SecTrustCreateWithCertificates(cfCertificates, policy, &trust);
                
                guard trust != nil, let pubKey = SecTrustCopyPublicKey(trust!) else {
                    completionHandler(.cancelAuthenticationChallenge, nil);
                    return;
                }
                
                var error:Unmanaged<CFError>?
                if let pubKeyData = SecKeyCopyExternalRepresentation(pubKey, &error) {
                    var keyWithHeader = Data(SessionDelegate.rsa2048Asn1Header);
                    keyWithHeader.append(pubKeyData as Data)
                    let sha256Key = sha256(keyWithHeader)
                    if(!SessionDelegate.google_com_pubkey.contains(sha256Key)) {
                        isServerTrusted = false
                    }
                } else {
                    isServerTrusted = false
                }
            } else { //Compare full certificate
                let remoteCertificateData = SecCertificateCopyData(certificate!) as Data;
                let sha256Data = sha256(remoteCertificateData);
                if(!SessionDelegate.google_com_full.contains(sha256Data)) {
                    isServerTrusted = false;
                }
            }
        }
        
        if(isServerTrusted) {
            let credential = URLCredential(trust: serverTrust);
            completionHandler(.useCredential, credential);
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil);
        }
        
    }
    
    func sha256(_ data : Data) -> String {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { ptr in
            _ = CC_SHA256(ptr.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
    
}
