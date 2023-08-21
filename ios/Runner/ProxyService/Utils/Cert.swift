//
//  Cert.swift
//  Runner
//
//  Created by Dubhe on 2023/8/20.
//

import Foundation

let certificate = [UInt8]("""
-----BEGIN CERTIFICATE-----
MIICmTCCAgICCQDyRuhp2+u6EDANBgkqhkiG9w0BAQsFADCBkDELMAkGA1UEBhMC
Q04xEjAQBgNVBAgMCUd1YW5nRG9uZzESMBAGA1UEBwwJR3VhbmdaaG91MRAwDgYD
VQQKDAdUb21kdWNrMRAwDgYDVQQLDAdUb21kdWNrMRMwEQYDVQQDDAp0b21kdWNr
LmNuMSAwHgYJKoZIhvcNAQkBFhFlcG9sbEBmb3htYWlsLmNvbTAeFw0yMzA4MjAx
MDE1MzZaFw0zMzA4MTcxMDE1MzZaMIGQMQswCQYDVQQGEwJDTjESMBAGA1UECAwJ
R3VhbmdEb25nMRIwEAYDVQQHDAlHdWFuZ1pob3UxEDAOBgNVBAoMB1RvbWR1Y2sx
EDAOBgNVBAsMB1RvbWR1Y2sxEzARBgNVBAMMCnRvbWR1Y2suY24xIDAeBgkqhkiG
9w0BCQEWEWVwb2xsQGZveG1haWwuY29tMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCB
iQKBgQC1uMa/4ON0F/IP39gJLF1bMFSxpQtNTpoKQLLxiMAF5EvroVtJJ43CmOcB
66IlYYmS1m4JNWYePZM1GZ2yRiPrtd41tyBuxLercwdcYIewuALrt6wTyG7TYZKm
iDo7FiWFb8WNI0P+lE71FadMC/a5pYc4+T5suxjYVKV3gb+I+wIDAQABMA0GCSqG
SIb3DQEBCwUAA4GBAJrL1uwZEr/uoPJd8VXom+2/IR3Dz+R7AwdC9TWMbu2sT3oQ
hijpaPhZxYqZtOLCsBR8amUdvlGXuVwvoa2gqBftbJ7S+nLyliXM31kVvPG+4tYx
sUgk0BHeZSInZjzYrxAqky7RLdbYTTa7sT3/9U36JT5YhRML8kiINpu2HW8c
-----END CERTIFICATE-----
""".utf8)

let privateKey = [UInt8]("""
-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQC1uMa/4ON0F/IP39gJLF1bMFSxpQtNTpoKQLLxiMAF5EvroVtJ
J43CmOcB66IlYYmS1m4JNWYePZM1GZ2yRiPrtd41tyBuxLercwdcYIewuALrt6wT
yG7TYZKmiDo7FiWFb8WNI0P+lE71FadMC/a5pYc4+T5suxjYVKV3gb+I+wIDAQAB
AoGABBCgEYa8T8qBVa2SLZJafEG2g0rH1/DcLUKJPjHq6bbTo++2FQrXdvTopfhZ
ZjCqXSiCyZ3yLNb/xf5OssAy6Xc2vY2cMg4hudOH3ELytXWIHwFDXkfnct3haCzE
cNtgU0tFFsxHQlexyOR9YG2Aj1gbsF9r0IKSTnm9JtCj7UECQQDq4k7e2pGjJvwh
WhCAEZ+wj/xger8JKSdPXfoFnGGu2fuDL7hpQ07DSpM9NDxUqp2isVbzXCVHzmLv
WpaPU+uLAkEAxg75/gknHWmTgkcApZ4ovG7/3OPgkvb01QoORQqID21MhuMA163O
YkhiJZYs5kYGPa2inWzxd7BBsuQaQp5GUQJANydu97uBKTt1RuucJkZ9JfuZepo4
E5GbTnK1y+19ro43FgX1mpoYe5keW+fRJtxtaY+U6E5B3suixauS4RMGowJAIRa9
c1CKJWLPDxPXqtO6kIim3HuBuGvjyXfNnIE+6/zhrSNdr6rM8SSQqSDmzW3jewh4
Q37A9LMQttde/8Q7kQJBAMJPuVJ7vjfwoTdMJKyTPDgOo8zCvBWBYvD9KrSieZgc
DEEbTmbPqc+UlVIzXu398aeHsMuy6GUZpVYG/8sYCPI=
-----END RSA PRIVATE KEY-----
""".utf8)