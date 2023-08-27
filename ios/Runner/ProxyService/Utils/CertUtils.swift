//
//  CertUtils.swift
//  Runner
//
//  Created by Dubhe on 2023/8/20.
//

import Foundation
import NIO
import CNIOBoringSSL
import NIOSSL

public class CertUtils: NSObject {
        
    public static var certPool = NSMutableDictionary()
    
//    public static func generateCert(host: String, rsaKey: NIOSSLPrivateKey, caKey: NIOSSLPrivateKey, caCert: NIOSSLCertificate) -> NIOSSLCertificate {
//            let caPriKey = caKey._ref.assumingMemoryBound(to: EVP_PKEY.self)
//            let key:UnsafeMutablePointer<EVP_PKEY> = rsaKey._ref.assumingMemoryBound(to: EVP_PKEY.self)//generateRSAPrivateKey()
//            /* Set the DN of the request. */
//            let name = CNIOBoringSSL_X509_NAME_new()
//            CNIOBoringSSL_X509_NAME_add_entry_by_txt(name, "C", MBSTRING_ASC, "SE", -1, -1, 0);
//            CNIOBoringSSL_X509_NAME_add_entry_by_txt(name, "ST", MBSTRING_ASC, "", -1, -1, 0);
//            CNIOBoringSSL_X509_NAME_add_entry_by_txt(name, "L", MBSTRING_ASC, "", -1, -1, 0);
//            CNIOBoringSSL_X509_NAME_add_entry_by_txt(name, "O", MBSTRING_ASC, "Company", -1, -1, 0);
//            CNIOBoringSSL_X509_NAME_add_entry_by_txt(name, "OU", MBSTRING_ASC, "", -1, -1, 0);
//            CNIOBoringSSL_X509_NAME_add_entry_by_txt(name, "CN", MBSTRING_ASC, host, -1, -1, 0);
//            /* Self-sign the request to prove that we posses the key. */
//    //        CNIOBoringSSL_X509_REQ_sign(req, key, CNIOBoringSSL_EVP_sha256())
//            /* Sign with the CA. */
//            let crt = CNIOBoringSSL_X509_new() // nil?
//            /* Set version to X509v3 */
//            CNIOBoringSSL_X509_set_version(crt, 2)
//            /* Generate random 20 byte serial. */
//            let serial = Int(arc4random_uniform(UInt32.max))
//    //        print("生成一次随机数-------")
//            CNIOBoringSSL_ASN1_INTEGER_set(CNIOBoringSSL_X509_get_serialNumber(crt), serial)
//    //        serial = 0
//            /* Set issuer to CA's subject. */
//            // TODO:1125:这句也会报错！fix
//            CNIOBoringSSL_X509_set_issuer_name(crt, CNIOBoringSSL_X509_get_subject_name(caCert._ref.assumingMemoryBound(to: X509.self)))
//            /* Set validity of certificate to 1 years. */
//            let notBefore = CNIOBoringSSL_ASN1_TIME_new()!
//            var now = time(nil)
//            CNIOBoringSSL_ASN1_TIME_set(notBefore, now)
//            let notAfter = CNIOBoringSSL_ASN1_TIME_new()!
//            now += 86400 * 365
//            CNIOBoringSSL_ASN1_TIME_set(notAfter, now)
//            CNIOBoringSSL_X509_set_notBefore(crt, notBefore)
//            CNIOBoringSSL_X509_set_notAfter(crt, notAfter)
//            CNIOBoringSSL_ASN1_TIME_free(notBefore)
//            CNIOBoringSSL_ASN1_TIME_free(notAfter)
//            /* Get the request's subject and just use it (we don't bother checking it since we generated it ourself). Also take the request's public key. */
//            CNIOBoringSSL_X509_set_subject_name(crt, name)
//            CNIOBoringSSL_X509_set_pubkey(crt, key)
//
//            CNIOBoringSSL_X509_NAME_free(name)
//
//            // 满足iOS13要求. See https://support.apple.com/en-us/HT210176
//            addExtension(x509: crt!, nid: NID_basic_constraints, value: "critical,CA:FALSE")
//            addExtension(x509: crt!, nid: NID_ext_key_usage, value: "serverAuth,OCSPSigning")
//            addExtension(x509: crt!, nid: NID_subject_key_identifier, value: "hash")
//            addExtension(x509: crt!, nid: NID_subject_alt_name, value: "DNS:" + host)
//
//            /* Now perform the actual signing with the CA. */
//            CNIOBoringSSL_X509_sign(crt, caPriKey, CNIOBoringSSL_EVP_sha256())
//
//            let copyCrt = CNIOBoringSSL_X509_dup(crt!)!
//            let cert = NIOSSLCertificate.fromUnsafePointer(takingOwnership: copyCrt)
//            CNIOBoringSSL_X509_free(crt!)
//            return cert
//        }
    
    public static func generateSelfSignedCert(host: String, keyBytes: [UInt8]) -> NIOSSLCertificate {
        let pkey = getPrivateKeyPointer(bytes: keyBytes)
        let x: OpaquePointer = CNIOBoringSSL_X509_new()!
        CNIOBoringSSL_X509_set_version(x, 2)
        let subject = CNIOBoringSSL_X509_NAME_new()
        CNIOBoringSSL_X509_NAME_add_entry_by_txt(subject, "C", MBSTRING_ASC, "SE", -1, -1, 0);
        CNIOBoringSSL_X509_NAME_add_entry_by_txt(subject, "ST", MBSTRING_ASC, "", -1, -1, 0);
        CNIOBoringSSL_X509_NAME_add_entry_by_txt(subject, "L", MBSTRING_ASC, "", -1, -1, 0);
        CNIOBoringSSL_X509_NAME_add_entry_by_txt(subject, "O", MBSTRING_ASC, "Company", -1, -1, 0);
        CNIOBoringSSL_X509_NAME_add_entry_by_txt(subject, "OU", MBSTRING_ASC, "", -1, -1, 0);
        CNIOBoringSSL_X509_NAME_add_entry_by_txt(subject, "CN", MBSTRING_ASC, host, -1, -1, 0);
//        CNIOBoringSSL_X509_NAME_add_entry_by_txt(x, "C", MBSTRING_ASC, "SE", -1, -1, 0);
//        CNIOBoringSSL_X509_NAME_add_entry_by_txt(x, "ST", MBSTRING_ASC, "", -1, -1, 0);
//        CNIOBoringSSL_X509_NAME_add_entry_by_txt(x, "L", MBSTRING_ASC, "", -1, -1, 0);
//        CNIOBoringSSL_X509_NAME_add_entry_by_txt(x, "O", MBSTRING_ASC, "Company", -1, -1, 0);
//        CNIOBoringSSL_X509_NAME_add_entry_by_txt(x, "OU", MBSTRING_ASC, "", -1, -1, 0);
//        CNIOBoringSSL_X509_NAME_add_entry_by_txt(x, "CN", MBSTRING_ASC, host, -1, -1, 0);
        
        // NB: X509_set_serialNumber uses an internal copy of the ASN1_INTEGER, so this is
        // safe, there will be no use-after-free.
        var serial = randomSerialNumber()
        CNIOBoringSSL_X509_set_serialNumber(x, &serial)
        
        let notBefore = CNIOBoringSSL_ASN1_TIME_new()!
        var now = time(nil)
        CNIOBoringSSL_ASN1_TIME_set(notBefore, now)
        CNIOBoringSSL_X509_set_notBefore(x, notBefore)
        CNIOBoringSSL_ASN1_TIME_free(notBefore)
        
        now += 60 * 60 * 60  // Give ourselves an hour
        let notAfter = CNIOBoringSSL_ASN1_TIME_new()!
        CNIOBoringSSL_ASN1_TIME_set(notAfter, now)
        CNIOBoringSSL_X509_set_notAfter(x, notAfter)
        CNIOBoringSSL_ASN1_TIME_free(notAfter)
        
        CNIOBoringSSL_X509_set_pubkey(x, pkey)
        
        var certificate = try! NIOSSLCertificate(bytes: certificate, format: .pem)
//        let commonName = "Tomduck"
//        commonName.withCString { (pointer: UnsafePointer<Int8>) -> Void in
//            pointer.withMemoryRebound(to: UInt8.self, capacity: commonName.lengthOfBytes(using: .utf8)) { (pointer: UnsafePointer<UInt8>) -> Void in
//                CNIOBoringSSL_X509_NAME_add_entry_by_NID(name,
//                                                         NID_commonName,
//                                                         MBSTRING_UTF8,
//                                                         UnsafeMutablePointer(mutating: pointer),
//                                                         CInt(commonName.lengthOfBytes(using: .utf8)),
//                                                         -1,
//                                                         0)
//            }
//        }
        var subjectName = CNIOBoringSSL_X509_get_subject_name(certificate.ref)
        CNIOBoringSSL_X509_set_issuer_name(x, subjectName)
        CNIOBoringSSL_X509_set_subject_name(x, subject)
        CNIOBoringSSL_X509_NAME_free(subject)
        addExtension(x509: x, nid: NID_basic_constraints, value: "critical,CA:FALSE")
        addExtension(x509: x, nid: NID_subject_key_identifier, value: "hash")
        addExtension(x509: x, nid: NID_subject_alt_name, value: "DNS:\(host)")
        addExtension(x509: x, nid: NID_ext_key_usage, value: "serverAuth,OCSPSigning")
        
        CNIOBoringSSL_X509_sign(x, pkey, CNIOBoringSSL_EVP_sha256())
        
        let copyCrt = CNIOBoringSSL_X509_dup(x)!
        let cert = NIOSSLCertificate(withOwnedReference: copyCrt)
        CNIOBoringSSL_X509_free(x)
        
        return cert
    }
    
    private static func randomSerialNumber() -> ASN1_INTEGER {
        let bytesToRead = 20
        let fd = open("/dev/urandom", O_RDONLY)
        precondition(fd != -1)
        defer {
            close(fd)
        }

        var readBytes = Array.init(repeating: UInt8(0), count: bytesToRead)
        let readCount = readBytes.withUnsafeMutableBytes {
            return read(fd, $0.baseAddress, bytesToRead)
        }
        precondition(readCount == bytesToRead)

        // Our 20-byte number needs to be converted into an integer. This is
        // too big for Swift's numbers, but BoringSSL can handle it fine.
        let bn = CNIOBoringSSL_BN_new()
        defer {
            CNIOBoringSSL_BN_free(bn)
        }
        
        _ = readBytes.withUnsafeBufferPointer {
            CNIOBoringSSL_BN_bin2bn($0.baseAddress, $0.count, bn)
        }

        // We want to bitshift this right by 1 bit to ensure it's smaller than
        // 2^159.
        CNIOBoringSSL_BN_rshift1(bn, bn)

        // Now we can turn this into our ASN1_INTEGER.
        var asn1int = ASN1_INTEGER()
        CNIOBoringSSL_BN_to_ASN1_INTEGER(bn, &asn1int)

        return asn1int
    }
    
    private static func getPrivateKeyPointer(bytes: [UInt8]) -> OpaquePointer {
        let ref = bytes.withUnsafeBytes { (ptr) -> OpaquePointer? in
            let bio = CNIOBoringSSL_BIO_new_mem_buf(ptr.baseAddress!, ptr.count)!
            defer {
                CNIOBoringSSL_BIO_free(bio)
            }
            
            return CNIOBoringSSL_PEM_read_bio_PrivateKey(bio, nil, nil, nil)
        }
        
        return ref!
    }
    
    private static func addExtension(x509: OpaquePointer, nid: CInt, value: String) {
        var extensionContext = X509V3_CTX()
        
        CNIOBoringSSL_X509V3_set_ctx(&extensionContext, x509, x509, nil, nil, 0)
        let ext = value.withCString { (pointer) in
            return CNIOBoringSSL_X509V3_EXT_nconf_nid(nil, &extensionContext, nid, UnsafeMutablePointer(mutating: pointer))
        }!
        CNIOBoringSSL_X509_add_ext(x509, ext, -1)
        CNIOBoringSSL_X509_EXTENSION_free(ext)
    }
}
