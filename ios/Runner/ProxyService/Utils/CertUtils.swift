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

let cert = [UInt8]("""
-----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgIUdW6SMghdpA59S4cIsKtHP69scJIwDQYJKoZIhvcNAQEL
BQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM
GEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yMzA4MjUxMDAxNTdaFw0yNDA4
MjQxMDAxNTdaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw
HwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQDxlCID1xFYXeK7c4ElHj0UjujhnZEEym3vkjOVSRqy
QQ9WMuUCadLp0qshNETFozO0swpB1emRp6e5vxB07DxYnTvig9EXX26Z9MP2dTEQ
JeUL31BYsUnNWqGBtvBA1SYAweozKt6IHMIcX4/zjYVLbGoQKpS1kjVmMcTVIjYN
dMEf88Ctgc1LhHIGv7qReWKAuhy+nqy9rCDdxdQlgoHcB4kC7D5ADTlumOTfuxCm
42nZI3ZKPVmzncsSOWunZihpYiOK7Ep1BYW0mf8y3iH0LUKsOmopslF+y51BA0Xv
fXOq9eeUwz4OC/xp4f0G4agF0Ia7VEpQkkMUkP5KuzMZAgMBAAGjRTBDMAwGA1Ud
EwQFMAMBAf8wFAYDVR0RBA0wC4IJanVlamluLmNuMB0GA1UdDgQWBBQzjzll38ky
Cq4MDL+jo96SN0VX1zANBgkqhkiG9w0BAQsFAAOCAQEA0VontWMd1iD7XUM6SnOg
KkfCeCLW/2ajM49//9lBN8PS5Da40SR/tiWLbOO6+392dfOE5BbeYJarurVjpHNd
M9N9r/6pLWDHg2lcowhXqHjwlkztUhd3b7tKrk71J04Qx+8rMADf9CvMjxC+k9yf
J0uAbPwHaTZy/0czBlBufB2f0t8GY3E34DGdXi5i8KxLYT1Ls8gkimij7qP02iI4
H7hsLpQhA328C0T2IdKt6UKvZmJBsfkHrGr6a6TgSEuVIuUu8/zUDjrF3NJUik3S
VYoKS5/RCWrBCehZwmKXl0bEQqr1u4+cRcSJ2BXPfPWBjUDmX7zfmVIxpT/LHACG
0g==
-----END CERTIFICATE-----
""".utf8)

let privateKey = [UInt8]("""
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA8ZQiA9cRWF3iu3OBJR49FI7o4Z2RBMpt75IzlUkaskEPVjLl
AmnS6dKrITRExaMztLMKQdXpkaenub8QdOw8WJ074oPRF19umfTD9nUxECXlC99Q
WLFJzVqhgbbwQNUmAMHqMyreiBzCHF+P842FS2xqECqUtZI1ZjHE1SI2DXTBH/PA
rYHNS4RyBr+6kXligLocvp6svawg3cXUJYKB3AeJAuw+QA05bpjk37sQpuNp2SN2
Sj1Zs53LEjlrp2YoaWIjiuxKdQWFtJn/Mt4h9C1CrDpqKbJRfsudQQNF731zqvXn
lMM+Dgv8aeH9BuGoBdCGu1RKUJJDFJD+SrszGQIDAQABAoIBAB7wEp8dRupjM6s/
8pUXV0kvuCFUtYLAje21coe20gVsEZO/dtalSM6LHUFmWTxaVz/YAgNGauAtcWx3
TJs8ucm7cTTkHr34iciLsSD6ByuDPt8TXU3Ofp4e8joTfJdA9Nn5+41L+y3BSRar
IltVj3GGU9r4KQ1LySzqSMPm2rdEMdkMMobh50bS9i/HwofgCZ2QinuECIfnELzZ
ZCR7WK4imuUezir2jFRz3eFEhV4SuLIlEvAWkg6OJKZ6sP3IbNJzY18SrO9m2elg
x1q3OZp9cnGuOM4hUgOTsEb3hiHv7/OVdvPPOqlWYGEn2Ky/2fVLVk/pVba5hcwz
S7pOCkUCgYEA+UP2dGSEookOHJuyUe6Na8f+mJT8RGwQ6oe79+AZUskNiC6JmPIa
1xUsFeSDFOOPuu6YoKY/oirKAne0zG1jRk/KNxgGz6W84pihSFXNVu7vgn0Owwhl
Zva8Ghyu7pew1yVCNP7AuD//N7LMZjMNhkB2ZCycrIevmhRijBZ2LlsCgYEA+BsB
H6ioy3NNpOnJxvVheLN7P3il+Yn0gF24kussFY9iSY3IgyZVeZdtxkD2sM1rkrTO
NcbWww9svi79TW/0tkXgGIpCW1w1KuU7CHC0yluuZSnfmPdyy3QXUzwBOKTvigW8
KSMqb1aiijo0L/0FL/rvNVbB7/RILx/uRd31BpsCgYBc4jNjOdWmz1V/2ZDAMRln
sVWwu8upH2/KRRwJCOvGyn6NYXIKmSThQtVzrvwde5KigKhFLM4HetRdyQeJKbXV
jIP4ta5MECFrep6W2soye8SqJjmq+WT30jdTr56L7+CIuyyJnOhpgAd1VN4PszR1
821qdKlJLSKFUtVKCFCvgwKBgQCnEmg7TXP9LPQILXa3B95PTW2dXD1IQOHo3zO/
m6XgDuH87gEsb8/3RUWiz3RPssTR0fdatz8/s09i8nmYf9+mLn+ths0QgJM9A4gx
MtRLwFk7vmrXsyoWX2Klpi6cWlUD+MCwYwHcX9ashm1GM3geyzfyDy4hy7ogIbxu
R/0MKQKBgEZA5/WmnfNNX3YxSZ394xRAfekAMcp/LmtsG5Nz6F7o0IRlz/AYQWmh
vVCZbyqzTeJEv7QI4XDoV/Ry/uDi9Ep87z9uxHAV1ognq/hHkgDb9106hDuo5Nmv
KPZGDY2Ju2YbcqCfUmh8sd+By7QfEF4m5t4UnW23HhpKeTe4FQ+s
-----END RSA PRIVATE KEY-----
""".utf8)

public class CertUtils: NSObject {
    
    private static let certificate: NIOSSLCertificate = try! NIOSSLCertificate(bytes: cert, format: .pem)
    public static var certPool = NSMutableDictionary()
    
    public static func generateSelfSignedCert(host: String) -> NIOSSLCertificate {
        let pkey = getPrivateKeyPointer(bytes: privateKey)
        let x: OpaquePointer = CNIOBoringSSL_X509_new()!
        CNIOBoringSSL_X509_set_version(x, 2)
        let subject = CNIOBoringSSL_X509_NAME_new()
        CNIOBoringSSL_X509_NAME_add_entry_by_txt(subject, "C", MBSTRING_ASC, "SE", -1, -1, 0);
        CNIOBoringSSL_X509_NAME_add_entry_by_txt(subject, "ST", MBSTRING_ASC, "", -1, -1, 0);
        CNIOBoringSSL_X509_NAME_add_entry_by_txt(subject, "L", MBSTRING_ASC, "", -1, -1, 0);
        CNIOBoringSSL_X509_NAME_add_entry_by_txt(subject, "O", MBSTRING_ASC, "Tomduck", -1, -1, 0);
        CNIOBoringSSL_X509_NAME_add_entry_by_txt(subject, "OU", MBSTRING_ASC, "", -1, -1, 0);
        CNIOBoringSSL_X509_NAME_add_entry_by_txt(subject, "CN", MBSTRING_ASC, host, -1, -1, 0);

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
        
        CNIOBoringSSL_X509_set_issuer_name(x, CNIOBoringSSL_X509_get_subject_name(certificate.ref))
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
