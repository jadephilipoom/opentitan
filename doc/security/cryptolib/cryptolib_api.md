# OpenTitan Cryptography Library Specification

Status: **RFC Approved by TC: 2022-05-13**

## Objective

This document is intended for users of the OpenTitan crypto library.
It defines C interfaces (APIs) and data structures to perform the required cryptographic operations such as encryption, signature generation etc., and lists implementation specific details that are opaque to a user.

The cryptographic API is defined for the following crypto modes:
- Symmetric ciphers (AES)
- Authenticated Encryption (AES-GCM, AES-KWP)
- Message digest (SHA2, SHA3)
- Keyed message digest (HMAC, KMAC)
- Signature generation and verification (RSA, ECC)
- Random number generation (DRBG)
- Key derivation (KDF)

Some of these crypto modes can operate on streaming data and several modes support asynchronous (non-blocking) modes of operation.
These are discussed in the later part of this specification.

## Symbols and Abbreviations

The following abbreviations are used in this specification:
- **AAD**: Additional Authenticated Data
- **AD**: Authenticated Decryption
- **AE**: Authenticated Encryption
- **AES**: Advanced Encryption Standard
- **CAVP**: Cryptographic Algorithm Validation Program
- **CFB**: Cipher Feedback mode
- **CMAC**: Cipher-based Message Authentication Code
- **CTR**: Counter mode
- **DH**: Diffie–Hellman algorithm
- **DRBG**: Deterministic Random Bit Generator
- **DSA**: Digital Signature Algorithm
- **ECB**: Electronic Codebook mode
- **ECC**: Elliptic Curve Cryptography
- **ECDH**: Elliptic Curve Diffie–Hellman
- **ECDSA**: Elliptic Curve Digital Signature Algorithm
- **FIPS**: Federal Information Processing Standard
- **GCM**: Galois Counter Mode
- **HMAC**: Keyed-Hash Message Authentication Code
- **ICV**: Integrity Check Value
- **IETF**: Internet Engineering Task Force
- **IV**: Initialization Vector
- **KDF**: Key Derivation Function
- **KEK**: Key-Encryption-Key
- **KMAC**: KECCAK Message Authentication Code
- **KWP**: AES Key Wrap with Padding
- **MAC**: Message Authentication Code
- **NIST**: National Institute of Standards and Technology
- **NRBG**: Non-deterministic Random Bit Generator
- **PKCS**: Public-Key Cryptography Standards
- **PRF**: Pseudorandom Function
- **PSS**: Probabilistic Signature Scheme
- **RSA**: Rivest–Shamir–Adleman, a public-key cryptosystem
- **RSASSA**: RSA Signature Schemes with Appendix
- **SHA**: Secure Hash Algorithm
- **XOF**: eXtendable-Output Function

## Final list of crypto algorithms and modes

The [cryptographic use case table][use-case-table] was used to capture the required cryptographic support in OpenTitan.
Based on the inputs from the cryptographic use case table, a list of crypto algorithms (and modes) for which an API needs to be exposed are identified and listed.

**Symmetric crypto**
-   AES-ECB
-   AES-CBC
-   AES-CFB
-   AES-OFB
-   AES-CTR
-   AES-KWP

**Authenticated Encryption**
-   AES-GCM

**HASH**
-   SHA2-256
-   SHA2-384
-   SHA2-512
-   SHA3-224
-   SHA3-256
-   SHA3-384
-   SHA3-512

**HASH-XOF**
-   SHAKE128
-   SHAKE256
-   cSHAKE128
-   cSHAKE256

**MAC**
-   HMAC-SHA256
-   KMAC128
-   KMAC256

**DRBG**
-   CTR-DRBG

**Streaming mode**
-   HASH (SHA2 modes only)
-   HMAC (HMAC-SHA256 only)

**KeyGen**
-   AES Keygen (all modes)
-   HMAC Keygen
-   KMAC Keygen
-   RSA Keygen
-   ECDSA Keygen
-   ECDH Keygen
-   Ed25519 Keygen
-   X25519 Keygen

**Asymmetric crypto**
-   RSA (Signature, Verification)
-   ECDSA (Signature, Verification)
-   ECDH Key exchange
-   Ed25519 (Signature, Verification)
-   X25519 Key exchange

**Asynchronous Interfaces**
-   RSA Keygen
-   RSA Signature, Verification
-   ECDSA Keygen
-   ECDSA (Signature, Verification)
-   ECDH Keygen
-   ECDH Key exchange
-   Ed25519 Keygen
-   Ed25519 (Signature, Verification)
-   X25519 Keygen
-   X25519 Key exchange

**KDF**
- HMAC-KDF (CTR mode)
- KMAC-KDF (CTR mode)

## Structs and Enums

This section defines the public and private data structures that are used with the API interfaces.

Private data structures are implementation specific, and are opaque to users of the API.

### Public data structures

Doxygen documentation for non-algorithm-specific data structures is [here](https://opentitan.org/gen/doxy/datatypes_8h.html).

{{#header-snippet sw/device/lib/crypto/include/datatypes.h crypto_status_t }}
{{#header-snippet sw/device/lib/crypto/include/datatypes.h crypto_status_value }}
{{#header-snippet sw/device/lib/crypto/include/datatypes.h key_type }}
{{#header-snippet sw/device/lib/crypto/include/datatypes.h aes_key_mode }}
{{#header-snippet sw/device/lib/crypto/include/datatypes.h hmac_key_mode }}
{{#header-snippet sw/device/lib/crypto/include/datatypes.h kmac_key_mode }}
{{#header-snippet sw/device/lib/crypto/include/datatypes.h rsa_key_mode }}
{{#header-snippet sw/device/lib/crypto/include/datatypes.h ecc_key_mode }}
{{#header-snippet sw/device/lib/crypto/include/datatypes.h kdf_key_mode }}
{{#header-snippet sw/device/lib/crypto/include/datatypes.h key_mode }}
{{#header-snippet sw/device/lib/crypto/include/aes.h aead_gcm_tag_len }}
{{#header-snippet sw/device/lib/crypto/include/datatypes.h crypto_unblinded_key }}
{{#header-snippet sw/device/lib/crypto/include/datatypes.h crypto_uint8_buf }}
{{#header-snippet sw/device/lib/crypto/include/datatypes.h crypto_const_uint8_buf }}
{{#header-snippet sw/device/lib/crypto/include/aes.h block_cipher_mode }}
{{#header-snippet sw/device/lib/crypto/include/aes.h aes_operation }}
{{#header-snippet sw/device/lib/crypto/include/aes.h aes_padding }}
{{#header-snippet sw/device/lib/crypto/include/hash.h hash_mode }}
{{#header-snippet sw/device/lib/crypto/include/hash.h xof_mode }}
{{#header-snippet sw/device/lib/crypto/include/mac.h kmac_mode }}
{{#header-snippet sw/device/lib/crypto/include/rsa.h rsa_padding }}
{{#header-snippet sw/device/lib/crypto/include/rsa.h rsa_hash }}
{{#header-snippet sw/device/lib/crypto/include/rsa.h rsa_private_key }}
{{#header-snippet sw/device/lib/crypto/include/rsa.h rsa_key_size }}
{{#header-snippet sw/device/lib/crypto/include/rsa.h rsa_public_key }}
{{#header-snippet sw/device/lib/crypto/include/ecc.h ecc_signature }}
{{#header-snippet sw/device/lib/crypto/include/ecc.h eddsa_sign_mode }}
{{#header-snippet sw/device/lib/crypto/include/ecc.h ecc_public_key }}
{{#header-snippet sw/device/lib/crypto/include/ecc.h ecc_domain }}
{{#header-snippet sw/device/lib/crypto/include/ecc.h ecc_curve_type }}
{{#header-snippet sw/device/lib/crypto/include/ecc.h ecc_curve }}
{{#header-snippet sw/device/lib/crypto/include/kdf.h kdf_type }}

### Private data structures

The following data structures are considered implementation specific.

{{#header-snippet sw/device/lib/crypto/include/datatypes.h crypto_blinded_key }}
{{#header-snippet sw/device/lib/crypto/include/hash.h hash_context }}
{{#header-snippet sw/device/lib/crypto/include/mac.h hmac_context }}
{{#header-snippet sw/device/lib/crypto/include/aes.h gcm_ghash_context }}

## Streaming and Asynchronous modes of operation

OpenTitan may implement additional API interfaces for several cryptographic modes based on the specific use-cases from applications such as ability to perform cryptographic operations on partial input data, capability to stop and resume cryptographic operations etc.
These API modes are detailed below.

### One shot and Streaming mode

Based on the input data availability, several cryptographic modes discussed in this specification implement two types of APIs: One-shot APIs and streaming mode APIs.

A one-shot API is used when the entire data to be operated is available upfront.
The entire data (pointer) is passed to the one-shot API as an input and the result is immediately available after the operation.

Streaming APIs are to support use-cases where the entire data to be transformed isn't available at the start of the operation and also in use-cases with limited memory availability.
Such streaming APIs operate iteratively over bytes of data, in blocks, as they are fed.
Partial inputs are buffered in the context until a full block is available to
process.
The partial result from the block is stored in a context parameter and is used again in the subsequent rounds, until the final round.
Only in the final round is the result of the cryptographic operation available.

Cryptographic modes such as HASH and HMAC support streaming APIs along with the default one-shot APIs.

**Crypto modes that support streaming modes:**
1.  HASH (SHA2 modes only)
2.  HMAC (HMAC-SHA256 only)

### Synchronous and Asynchronous mode

Synchronous mode of operation is when the crypto call does not return to the caller until the cryptographic operation is complete.
This mode blocks the CPU and no other process can utilize it until it returns, hence it is also known as blocking mode of operation.

OpenTitan maintains compatibility with TockOS, which has a low latency return call programming model where the CPU blocking should not be longer than (5-10ms).
Cryptographic modes which take longer time to complete their operation must implement an asynchronous mode to provide non-blocking mode of operation.

The [asynchronous API for OpenTitan proposal][async-proposal] defines a way to asynchronously run the long running cryptographic operations that use OTBN.
The OTBN accelerator itself is treated as a "separate thread"to achieve this intended non-blocking operation.

Each asynchronous operation will have two function calls associated with it:
- **\<algorithm\>\_async\_start**
  - Takes input arguments. Checks if OTBN is idle and cleared. If so: does any
    necessary synchronous preprocessing, initializes OTBN, and starts the OTBN
    routine. Returns "OK"if the operation was successfully started.
- **\<algorithm\>\_async\_finalize**
  - Takes caller-allocated output buffers. Checks if the app loaded onto OTBN
    is the expected one; if not, returns "Invalid Input"status message. Checks
    OTBN status and returns "OK" and output or "Async Incomplete" or "Internal
    Error"

Cryptographic modes such as RSA and ECC that take a longer time support asynchronous APIs along with the default synchronous APIs.

**Crypto modes that support asynchronous modes:**
1.  RSA Keygen
2.  RSA Signature
3.  RSA Verification
4.  ECDSA Keygen
5.  ECDSA Signature
6.  ECDSA Verification
7.  ECDH Keygen
8.  ECDH Key exchange
9.  Ed25519 Keygen
10. Ed25519 Signature
11. Ed25519 Verification
12. X25519 Keygen
13. X25519 Key exchange

## AES

Advanced Encryption Standard (AES) is the symmetric block cipher for encryption and decryption.
AES operates with a data block length of 128 bits and with cipher keys of length 128, 192 or 256 bits.

OpenTitan's [AES block][aes] unit is a cryptographic accelerator, implemented in hardware, to perform encryption and decryption on 16-byte blocks of data.
OpenTitan AES IP supports five (5) confidentiality modes of operation, with a key length of 128 bits, 192 bits and 256 bits.

OpenTitan AES supported confidentiality modes:
1.  Electronic Codebook (ECB)
2.  Cipher Block Chaining (CBC)
3.  Cipher Feedback (CFB)
4.  Output Feedback (OFB)
5.  Counter (CTR)

APIs are defined to support five block cipher (confidentiality) modes of operation: AES-\[ECB, CBC, CFB, OFB and CTR\] and AES-\[GCM, KWP\] for authenticated encryption.
Padding schemes are defined in the **aes\_padding\_t** structure from [this section](#structs-and-enums).

Kindly refer to the links in the [reference](#reference) section for more information on AES and the block cipher modes of operation.

Doxygen documentation for AES-based algorithms is [here](https://opentitan.org/gen/doxy/include_2aes_8h.html).

### API

A one-shot API initializes the required block cipher mode of operation (ECB, CBC, CFB, OFB or CTR) and performs the required encryption/decryption.

#### Key generation

{{#header-snippet sw/device/lib/crypto/include/aes.h otcrypto_aes_keygen }}


#### One-shot AES

{{#header-snippet sw/device/lib/crypto/include/aes.h otcrypto_aes }}

#### AES-GCM

AES-GCM (Galois/Counter Mode) is used for authenticated encryption of the associated data and provides both confidentiality and authenticity of data.
Confidentiality using a variation of the AES counter mode and authenticity of the confidential data using a universal hash function that is defined over a binary Galois field.
GCM can also provide authentication assurance for additional data that is not encrypted.

Kindly refer to the [block cipher GCM specification][gcm-spec] and the links in the [reference](#reference) section for more information on AES-GCM mode and its construction.

AES-GCM consists of two related functions:
- an authenticated encryption function to generate a ciphertext and an authentication tag from the plaintext, and
- an authenticated decryption function to verify the tag and to recover the plaintext from the ciphertext.

In addition, we expose the internal GHASH and GCTR operation that GCM relies upon (from [NIST SP800-38D][gcm-spec], section 6.4).
This allows flexibility for use-cases that need custom GCM constructs: for example, we do not provide AES-GCM in streaming mode here because it encourages decryption and processing of unauthenticated data, but some users may need it for compatibility purposes.
Additionally, the GHASH operation can be used to construct GCM with block ciphers other than AES.

##### GCM - Authenticated Encryption and Decryption

{{#header-snippet sw/device/lib/crypto/include/aes.h otcrypto_aes_encrypt_gcm }}
{{#header-snippet sw/device/lib/crypto/include/aes.h otcrypto_aes_decrypt_gcm }}

##### GCM - GHASH and GCTR

{{#header-snippet sw/device/lib/crypto/include/aes.h otcrypto_gcm_ghash_init }}
{{#header-snippet sw/device/lib/crypto/include/aes.h otcrypto_gcm_ghash_update }}
{{#header-snippet sw/device/lib/crypto/include/aes.h otcrypto_gcm_ghash_final }}
{{#header-snippet sw/device/lib/crypto/include/aes.h otcrypto_aes_gcm_gctr }}

#### AES-KWP

AES Key Wrap (KW) is a deterministic authenticated-encryption mode of operation of the AES algorithm.
AES-KW is designed to protect the confidentiality and the authenticity/integrity of cryptographic keys.
A variant of the Key-wrap algorithm with an internal padding scheme called Key-wrap with padding (KWP) is defined for interoperability.

Kindly refer to the [block cipher key-wrapping specification][kwp-spec] and the links in the [reference](#reference) section for more information on AES-KWP mode and its construction.

AES KWP mode comprises two related functions, authenticated encryption and authenticated decryption.

{{#header-snippet sw/device/lib/crypto/include/aes.h otcrypto_aes_kwp_encrypt }}
{{#header-snippet sw/device/lib/crypto/include/aes.h otcrypto_aes_kwp_decrypt }}

## HASH

A cryptographic hash (HASH) function is a deterministic one-way function that maps an arbitrary length message to a fixed length digest.
Hash algorithms are used to verify the integrity of the message, i.e. any change to the message will, with a very high probability, result in a different message digest.

OpenTitan's [KMAC block][kmac] supports the fixed digest length SHA3\[224, 256, 384, 512\] cryptographic hash functions, and the extendable-output functions of variable digest length SHAKE\[128, 256\] and cSHAKE\[128, 256\].
SHA-2 functions are supported by [OTBN][otbn] and SHA-256 is supported by the [HMAC block][hmac]

APIs are defined to support the following modes: SHA2\[256, 384, 512\], SHA3\[224, 256, 384, 512\], SHAKE\[128, 256\] and cSHAKE\[128,256\].

For **SHA2 only**, the hash API supports both one-shot and streaming modes of operation.

Kindly refer to the links in the [reference](#reference) section for more information on HASH construction and supported modes.

Digest length for SHA2 and SHA3 hash modes:

| **Hash Mode** | **Digest Length (bytes)** |
| ------------- | ------------------------- |
| SHA-256       | 32                        |
| SHA-384       | 48                        |
| SHA-512       | 64                        |
| SHA3-224      | 28                        |
| SHA3-256      | 32                        |
| SHA3-384      | 48                        |
| SHA3-512      | 64                        |

### One-shot Hash API

This mode is used when the entire data to be hashed is available upfront.

This is a generic hash API where the required digest type and length is passed as an input parameter.
The supported hash modes are SHA256, SHA384, SHA512, SHA3-224, SHA3-256, SHA3-384 and SHA3-512.

{{#header-snippet sw/device/lib/crypto/include/hash.h otcrypto_hash }}


### HASH-XOF

Two separate APIs (SHAKE, CSHAKE) are defined below for the SHA3 based Extendable-Output Functions (XOF).
The supported XOF modes for SHAKE are SHAKE128 and  SHAKE256; and for CSHAKE are cSHAKE128 and cSHAKE256.

<!-- TODO: fix header to have shake/cshake! -->
{{#header-snippet sw/device/lib/crypto/include/hash.h otcrypto_xof }}

### Streaming Hash API

The streaming mode API is used for incremental hashing use-case, where the data to be hashed is split and passed in multiple blocks.

The streaming mode is supported **only for SHA2** hash modes (SHA256, SHA384, SHA512).

It is implemented using the INIT/UPDATE/FINAL structure:
- **INIT** initializes the context parameter.
- **UPDATE** is called repeatedly with message bytes to be hashed.
- **FINAL** computes the final digest, copies the result to the output buffer, and clears context.

{{#header-snippet sw/device/lib/crypto/include/hash.h otcrypto_hash_init }}
{{#header-snippet sw/device/lib/crypto/include/hash.h otcrypto_hash_update }}
{{#header-snippet sw/device/lib/crypto/include/hash.h otcrypto_hash_final }}

## MAC

A message authentication code provides integrity and authentication checks using a secret key shared between two parties.
OpenTitan supports two kinds of MACS:
- HMAC, a simple construction based on cryptographic hash functions
- KMAC, a Keccak-based MAC

OpenTitan's [HMAC block][hmac] supports HMAC-SHA256 mode of operation with a key length of 256 bits.
The [KMAC block][kmac] supports KMAC128 and KMAC 256, with a key length of \[128, 192, 256, 384, 512\] bits.

APIs are defined in the following section for HMAC-SHA256 and KMAC256.
Key sizes supported are 256 bits for HMAC and \[128, 192, 256, 384, 512\] bits for KMAC.

The HMAC API supports both one-shot and streaming modes of operation.

Kindly refer to the links in the [reference](#reference) section for more information on the HMAC and the KMAC constructions and supported modes.

### Key Generation

{{#header-snippet sw/device/lib/crypto/include/mac.h otcrypto_mac_keygen }}

### One-shot API

This mode is used when the entire data to be authenticated is available upfront.

{{#header-snippet sw/device/lib/crypto/include/mac.h otcrypto_hmac }}
{{#header-snippet sw/device/lib/crypto/include/mac.h otcrypto_kmac }}

### Streaming API

The streaming mode API is used for incremental hashing use-case, where the data to be hashed is split and passed in multiple blocks.

The streaming mode is supported **only for HMAC-SHA256**.

It is implemented using the INIT/UPDATE/FINAL structure:
- **INIT** initializes the context parameter.
- **UPDATE** is called repeatedly with message bytes.
- **FINAL** computes the final tag, copies the result to the output buffer, and clears context.

{{#header-snippet sw/device/lib/crypto/include/mac.h otcrypto_hmac_init }}
{{#header-snippet sw/device/lib/crypto/include/mac.h otcrypto_hmac_update }}
{{#header-snippet sw/device/lib/crypto/include/mac.h otcrypto_hmac_final }}

## RSA

RSA (Rivest-Shamir-Adleman) is an asymmetric cryptographic algorithm used for authentication and data confidentiality.

### RSA Key Pair

RSA schemes employ two key types: RSA public key (known to everyone) and RSA private key (sensitive).
Together they form an RSA key pair.

The RSA *public key* is denoted by (n, e), where:
- n is the RSA modulus, a positive integer
- e is the RSA public exponent, a positive integer

The RSA *private key* is denoted by the pair (n, d), where
- n is the RSA modulus, a positive integer
- d is the RSA private exponent, a positive integer

### RSA Supported Modes

OpenTitan uses the [OpenTitan Big Number Accelerator][otbn], an asymmetric cryptographic accelerator, to speed up the underlying RSA operations.

APIs are defined in the to support RSA Key generation and RSA digital signature generation and a verification for the key lengths of \[1024, 2048, 3072, 4096\] bits.
Two PKCS signature schemes are supported: (RSASSA-PSS, RSASSA-PKCS1-v1_5).
Supported padding schemes are defined in the **rsa\_padding\_t** structure in [this section](#structs-and-enums).

The API for RSA supports [asynchronous](#synchronous-and-asynchronous-mode) operation.

Kindly refer to the links in the [reference](#reference) section for more information on RSA.

### Hash Function for RSA Signatures

An approved hash function is used during the generation digital signatures.
The length in bits of the hash function output block must meet or exceed the security strength associated with the bit length of the modulus n in order to uphold RSA's security guarantees.

It is recommended that the security strength of the modulus and the security strength of the hash function be the same unless an agreement has been made between participating entities to use a stronger hash function.

### Synchronous (Blocking Mode) API

#### Key Generation

{{#header-snippet sw/device/lib/crypto/include/rsa.h otcrypto_rsa_keygen }}

#### Signature

{{#header-snippet sw/device/lib/crypto/include/rsa.h otcrypto_rsa_sign }}
{{#header-snippet sw/device/lib/crypto/include/rsa.h otcrypto_rsa_verify }}

ECC

Elliptic curve cryptography (ECC) is a public-key cryptography based on
elliptic curves over finite fields and is widely used for key agreement
and signature schemes. ECC has an advantage over other similar
public-key crypto systems as it uses shorter key-lengths to provide
equivalent security.

Two key types are employed in the ECC primitive: ECC public key (Q) and
ECC private key (d). The public key can be known to everyone, and is
used in key agreement and to verify messages. The private key is
sensitive, known only to the user and is used to sign messages.

**ECC Key Pair**

ECC *private key* is denoted by 'd' where

d positive integer between {1,...n−}, (where n is the order of the
subgroup)

ECC *public key* is denoted by Q, and Q = dG, where

d private key

G base-point of the sub group

**Supported Modes**

OpenTitan uses the OpenTitan Big Number Accelerator (), an asymmetric
cryptographic accelerator, to speed up the underlying ECC operations.
Only elliptic curves over prime finite fields (P) are supported.
Elliptic curves of the short Weierstrass form, Montgomery form, and
twisted Edward form are supported.

For short Weierstrass form three predefined named curves are supported
(NIST P256, NIST P384 and brainpool 256) along with support for
user-defined generic curves. Programmers have the option to set
predefined domain parameters for named curves or input their own domain
parameters for a user-defined curve. For the Montgomery form, only
X25519 is supported. For twisted Edwards form only Ed25519 is supported.

APIs are defined in the to support key generation, key agreement and
signature schemes for Weierstrass curves and X25519/Ed25519.

The APIs for ECC key generation, ECDSA, EdDSA and key agreement modes
support two kinds of use cases: and an mode of operation.

(**Synchronous API**: Blocking mode, where the crypto call does not
return to the program until the crypto operation is complete ; and an
**Asynchronous mode **where long-running cryptographic operations that
use OTBN accelerator are called asynchronously to let other shorter
computations to happen in the background. This is to support TockOS's
low latency return call programming model, which requires long running
operations to implement asynchronous interfaces).

Kindly refer to the links in the section for more information on ECC
construction and curve types, NIST and brainpool named curves, key
generation and agreement, ECDSA and EdDSA.

API / Wrapper

Synchronous (blocking mode) API

ECDSA Keygen

/\*\*

\* Performs the key generation for ECDSA operation.

\*

\* Computes private key (d) and public key (Q) keys for ECDSA

\* operation.

\*

\* The domain_parameter field of the \`elliptic_curve\` is required

\* only for a custom curve. For named curves this field is ignored

\* and can be set to NULL.

\*

\* \@param elliptic_curve Pointer to the elliptic curve to be used

\* \@param private_key Pointer to the blinded private key (d) struct

\* \@param public_key Pointer to the unblinded public key (Q) struct

\* \@return crypto_status_t Result of the ECDSA key generation

\*/

**crypto\_status\_t** **otcrypto\_ecdsa\_keygen**(**ecc\_curve\_t**
\*elliptic_curve,\
** crypto\_blinded\_key\_t **\*private_key,\
** ecc\_public\_key\_t **\*public_key);

ECDSA Signature

/\*\*

\* Performs the ECDSA digital signature generation.

\*

\* The domain_parameter field of the \`elliptic_curve\` is required

\* only for a custom curve. For named curves this field is ignored

\* and can be set to NULL.

\*

\* \@param private_key Pointer to the blinded private key (d) struct

\* \@param input_message Input message to be signed

\* \@param elliptic_curve Pointer to the elliptic curve to be used

\* \@param signature Pointer to the signature struct with (r,s) values

\* \@return crypto_status_t Result of the ECDSA signature generation

\*/

**crypto\_status\_t** **otcrypto\_ecdsa\_sign**(const
**crypto\_blinded\_key\_t** \*private_key,\
**crypto\_const\_uint8\_buf\_t** input_message,\
**ecc\_curve\_t** \*elliptic_curve,\
** ecc\_signature\_t** \*signature);

Deterministic ECDSA Signature

/\*\*

\* Performs the deterministic ECDSA digital signature generation.

\*

\* In the case of deterministic ECDSA, the random value 'k'for the

\* signature generation is deterministically generated from the

\* private key and the input message. Refer to for details.

\*

\* The domain_parameter field of the \`elliptic_curve\` is required

\* only for a custom curve. For named curves this field is ignored

\* and can be set to NULL.

\*

\* \@param private_key Pointer to the blinded private key (d) struct

\* \@param input_message Input message to be signed

\* \@param elliptic_curve Pointer to the elliptic curve to be used

\* \@param signature Pointer to the signature struct with (r,s) values

\* \@return crypto_status_t Result of the deterministic ECDSA signature

\* generation

\*/

**crypto\_status\_t** **otcrypto\_deterministic\_ecdsa\_sign**(\
const **crypto\_blinded\_key\_t **\*private_key,

**crypto\_const\_uint8\_buf\_t** input_message,

**ecc\_curve\_t** \*elliptic_curve,\
** ecc\_signature\_t** \*signature);

ECDSA Verification

/\*\*

\* Performs the ECDSA digital signature verification.

\*

\* The domain_parameter field of the \`elliptic_curve\` is required

\* only for a custom curve. For named curves this field is ignored

\* and can be set to NULL.

\*

\* \@param public_key Pointer to the unblinded public key (Q) struct

\* \@param input_message Input message to be signed for verification

\* \@param signature Pointer to the signature to be verified

\* \@param elliptic_curve Pointer to the elliptic curve to be used

\* \@param verification_result Result of verification (Pass/Fail)

\* \@return crypto_status_t Result of the ECDSA verification operation

\*/

**crypto\_status\_t** **otcrypto\_ecdsa\_verify** (const
**ecc\_public\_key\_t** \*public_key,\
** crypto\_const\_uint8\_buf\_t **input_message,\
** ecc\_signature\_t** \*signature,\
** ecc\_curve\_t** \*elliptic_curve,\
** verification\_status\_t **\*verification_result);

ECDH Keygen

/\*\*

\* Performs the key generation for ECDH key agreement.

\*

\* Computes private key (d) and public key (Q) keys for ECDSA

\* operation.

\*

\* The domain_parameter field of the \`elliptic_curve\` is required

\* only for a custom curve. For named curves this field is ignored

\* and can be set to NULL.

\*

\* \@param elliptic_curve Pointer to the elliptic curve to be used

\* \@param private_key Pointer to the blinded private key (d) struct

\* \@param public_key Pointer to the unblinded public key (Q) struct

\* \@return crypto_status_t Result of the ECDH key generation

\*/

**crypto\_status\_t** **otcrypto\_ecdh\_keygen**(**ecc\_curve\_t**
\*elliptic_curve**,**\
** crypto\_blinded\_key\_t **\*private_key**,**\
** ecc\_public\_key\_t** \*public_key);

ECDH

/\*\*

\* Performs Elliptic Curve Diffie Hellman shared secret generation.

\*

\* The domain_parameter field of the \`elliptic_curve\` is required

\* only for a custom curve. For named curves this field is ignored

\* and can be set to NULL.

\*

\* \@param private_key Pointer to the blinded private key (d) struct

\* \@param public_key Pointer to the unblinded public key (Q) struct

\* \@param elliptic_curve Pointer to the elliptic curve to be used

\* \@param shared_secret Pointer to generated blinded shared key struct

\* \@return crypto_status_t Result of ECDH shared secret generation

\*/

**crypto\_status\_t** **otcrypto\_ecdh**(const **crypto\_blinded\_key\_t
**\*private_key,\
const **ecc\_public\_key\_t** \*public_key,\
**ecc\_curve\_t** \*elliptic_curve,\
**crypto\_blinded\_key\_t **\*shared_secret);

Ed25519 Key Gen

/\*\*

\* Generates a new Ed25519 key pair.

\*

\* Computes the private exponent (d) and public key (Q) based on

\* Curve25519.

\*

\* No domain_parameter is needed and is automatically set for Ed25519.

\*

\* \@param private_key Pointer to the blinded private key struct

\* \@param public_key Pointer to the unblinded public key struct

\* \@return crypto_status_t Result of the Ed25519 key generation

\*/

**crypto\_status\_t**
**otcrypto\_ed25519\_keygen**(**crypto\_blinded\_key\_t
**\*private_key,\
** crypto\_unblinded\_key\_t** \*public_key);

Ed25519 Signature

/\*\*

\* Generates an Ed25519 digital signature.

\*

\* \@param private_key Pointer to the blinded private key struct

\* \@param input_message Input message to be signed

\* \@param sign_mode Parameter for EdDSA or Hash EdDSA sign mode

\* \@param signature Pointer to the EdDSA signature with (r,s) values

\* \@return crypto_status_t Result of the EdDSA signature generation

\*/

**crypto\_status\_t** **otcrypto\_ed25519\_sign**(const
**crypto\_blinded\_key\_t **\*private_key,\
** crypto\_const\_uint8\_buf\_t **input_message,\
** eddsa\_sign\_mode\_t** sign_mode,\
** ecc\_signature\_t** \*signature);

Ed25519 Verification

/\*\*

\* Verifies an Ed25519 signature.

\*

\* \@param public_key Pointer to the unblinded public key struct

\* \@param input_message Input message to be signed for verification

\* \@param sign_mode Parameter for EdDSA or Hash EdDSA sign mode

\* \@param signature Pointer to the signature to be verified

\* \@param verification_result Returns the result of signature

\* verification (Pass/Fail)

\* \@return crypto_status_t Result of the EdDSA verification operation

\*/

**crypto\_status\_t** **otcrypto\_ed25519\_verify**(\
const **crypto\_unblinded\_key\_t **\*public_key,\
**crypto\_const\_uint8\_buf\_t **input_message,\
**eddsa\_sign\_mode\_t** sign_mode,\
** ecc\_signature\_t** \*signature,\
** verification\_status\_t **\*verification_result);

X25519 Key Gen

/\*\*

\* Generates a new key pair for X25519 key exchange.

\*

\* Computes the private scalar (d) and public key (Q) based on

\* Curve25519.

\*

\* No domain_parameter is needed and is automatically set for X25519.

\*

\* \@param private_key Pointer to the blinded private key struct

\* \@param public_key Pointer to the unblinded public key struct

\* \@return crypto_status_t Result of the X25519 key generation

\*/

**crypto\_status\_t**
**otcrypto\_x25519\_keygen**(**crypto\_blinded\_key\_t **\*private_key,\
** crypto\_unblinded\_key\_t** \*public_key);

X25519 Key exchange

/\*\*

\* Performs the X25519 Diffie Hellman shared secret generation.

\*

\* \@param private_key Pointer to blinded private key (u-coordinate)

\* \@param public_key Pointer to the public scalar from the sender

\* \@param shared_secret Pointer to shared secret key (u-coordinate)

\* \@return crypto_status_t Result of the X25519 operation

\*/

**crypto\_status\_t** **otcrypto\_x25519**(const
**crypto\_blinded\_key\_t** \*private_key**,**\
** **const **crypto\_unblinded\_key\_t **\*public_key**,**\
** crypto\_blinded\_key\_t **\*shared_secret);

Asynchronous APIs

The defines a way to asynchronously run the long running cryptographic
operations that use OTBN. The OTBN accelerator itself is treated as a
"separate thread"to achieve non-blocking operation.

Each asynchronous operation will have two function calls associated with
it:

-   **\<algorithm\>\_async\_start**

    -   Takes input arguments. Checks if OTBN is idle and cleared. If
        so: does any necessary synchronous preprocessing, initializes
        OTBN, and starts the OTBN routine. Returns "OK"if the operation
        was successfully started

```{=html}
<!-- -->
```
-   **\<algorithm\>\_async\_finalize**

    -   Takes caller-allocated output buffers. Checks if the app loaded
        onto OTBN is the expected one; if not, returns "Invalid
        Input"status message. Checks OTBN status and returns "OK"and
        output or "Async Incomplete"or "Internal Error"

APIs are defined below to support non-blocking operation for RSA and ECC
modes.

RSA

Asynchronous RSA Key Generation

/\*\*

\* Starts the asynchronous RSA key generation function.

\*

\* Initializes OTBN and starts the OTBN routine to compute the RSA

\* private key (d), RSA public key exponent (e) and modulus (n).

\*

\* Returns \`kCryptoStatusOK\` if the operation was successfully

\* started, or\`kCryptoStatusInternalError\` if the operation cannot be

\* started.

\*

\* \@param required_key_len Requested key length

\* \@return crypto_status_t Result of async RSA keygen start operation

\*/

**crypto\_status\_t** **otcrypto\_rsa\_keygen\_async\_start**(\
**rsa\_key\_size\_t** required_key_len);

/\*\*

\* Finalizes the asynchronous RSA key generation function.

\*

\* Returns \`kCryptoStatusOK\` and copies the RSA private key (d), RSA

\* public key exponent (e) and modulus (n) if the OTBN status is done,

\* or \`kCryptoStatusAsyncIncomplete\` if the OTBN is busy or

\* \`kCryptoStatusInternalError\` if there is an error.

\*

\* \@param rsa_public_key Pointer to RSA public exponent struct

\* \@param rsa_private_key Pointer to RSA private exponent struct

\* \@return crypto_status_t Result of asynchronous RSA keygen finalize

\* operation

\*/

**crypto\_status\_t** **otcrypto\_rsa\_keygen\_async\_finalize**(\
**rsa\_public\_key\_t** \*rsa_public_key,\
**rsa\_private\_key\_t **\*rsa_private_key);

Asynchronous RSA Signature

/\*\*

\* Starts the asynchronous digital signature generation function.

\*

\* Initializes OTBN and starts the OTBN routine to compute the digital

\* signature on the input message.

\*

\* Returns \`kCryptoStatusOK\` if the operation was successfully

\* started, or\`kCryptoStatusInternalError\` if the operation cannot be

\* started.

\*

\* \@param rsa_private_key Pointer to RSA private exponent struct

\* \@param input_message Input message to be signed

\* \@param padding_mode Padding scheme to be used for the data

\* \@param hash_mode Hashing scheme to be used for the signature scheme

\* \@return crypto_status_t Result of async RSA sign start operation

\*/

**crypto\_status\_t** **otcrypto\_rsa\_sign\_async\_start**(\
const **rsa\_private\_key\_t **\*rsa_private_key,\
**crypto\_const\_uint8\_buf\_t **input_message,\
**rsa\_padding\_t** padding_mode,\
**rsa\_hash\_t** hash_mode);

/\*\*

\* Finalizes the asynchronous digital signature generation function.

\*

\* Returns \`kCryptoStatusOK\` and copies the signature if the OTBN

\* status is done, or \`kCryptoStatusAsyncIncomplete\` if the OTBN is

\* busy or \`kCryptoStatusInternalError\` if there is an error.

\*

\* The caller should allocate space for the \`signature\` buffer,\
\* (expected length same as modulus length from \`rsa_private_key\`),

\* and set the length of expected output in the \`len\` field of

\* \`signature\`. If the user-set length and the output length does not

\* match, an error message will be returned.

\*

\* \@param signature Pointer to generated signature struct

\* \@return crypto_status_t Result of async RSA sign finalize operation

\*/

**crypto\_status\_t**
**otcrypto\_rsa\_sign\_async\_finalize**(**crypto\_uint8\_buf\_t
**\*signature);

Asynchronous - RSA Verification

/\*\*

\* Starts the asynchronous signature verification function.

\*

\* Initializes OTBN and starts the OTBN routine to recover the message

\* from the input signature.

\*

\* \@param rsa_public_key Pointer to RSA public exponent struct

\* \@param signature Pointer to the input signature to be verified

\* \@return crypto_status_t Result of async RSA verify start operation

\*/

**crypto\_status\_t** **otcrypto\_rsa\_verify\_async\_start**(\
const **rsa\_public\_key\_t **\*rsa_public_key,\
** crypto\_const\_uint8\_buf\_t **signature);

/\*\*

\* Finalizes the asynchronous signature verification function.

\*

\* Returns \`kCryptoStatusOK\` and populates the \`verification result\`

\* if the OTBN status is done, or \`kCryptoStatusAsyncIncomplete\` if

\* OTBN is busy or \`kCryptoStatusInternalError\` if there is an error.

\* The (hash of) recovered message is compared against the input

\* message and a PASS or FAIL is returned.

\*

\* \@param input_message Input message to be signed for verification

\* \@param padding_mode Padding scheme to be used for the data

\* \@param hash_mode Hashing scheme to be used for the signature scheme

\* \@param verification_result Returns the result of verification

\* \@return crypto_status_t Result of async RSA verify finalize

\* operation

\*/

**crypto\_status\_t** **otcrypto\_rsa\_verify\_async\_finalize**(\
**crypto\_const\_uint8\_buf\_t **input_message,\
**rsa\_padding\_t** padding_mode,\
**rsa\_hash\_t** hash_mode,\
** verification\_status\_t **\*verification_result);

ECC

Asynchronous - ECDSA Keygen

/\*\*

\* Starts the asynchronous key generation for ECDSA operation.

\*

\* Initializes OTBN and starts the OTBN routine to compute the private

\* key (d) and public key (Q) for ECDSA operation.

\*

\* The domain_parameter field of the \`elliptic_curve\` is required

\* only for a custom curve. For named curves this field is ignored

\* and can be set to NULL.

\*

\* Returns \`kCryptoStatusOK\` if the operation was successfully

\* started, or\`kCryptoStatusInternalError\` if the operation cannot be

\* started.

\*

\* \@param elliptic_curve Pointer to the elliptic curve to be used

\* \@return crypto_status_t Result of asynchronous ECDSA keygen start

\* operation.

\*/

**crypto\_status\_t** **otcrypto\_ecdsa\_keygen\_async\_start**(\
** ecc\_curve\_t** \*elliptic_curve);

/\*\*

\* Finalizes the asynchronous key generation for ECDSA operation.

\*

\* Returns \`kCryptoStatusOK\` and copies the private key (d) and public

\* key (Q), if the OTBN status is done, or

\* \`kCryptoStatusAsyncIncomplete\` if the OTBN is busy or

\* \`kCryptoStatusInternalError\` if there is an error.

\*

\* \@param private_key Pointer to the blinded private key (d) struct

\* \@param public_key Pointer to the unblinded public key (Q) struct

\* \@return crypto_status_t Result of asynchronous ECDSA keygen

\* finalize operation

\*/

**crypto\_status\_t** **otcrypto\_ecdsa\_keygen\_async\_finalize**(\
**crypto\_blinded\_key\_t **\*private_key,\
**ecc\_public\_key\_t **\*public_key);

Asynchronous - ECDSA Signature

/\*\*

\* Starts the asynchronous ECDSA digital signature generation.

\*

\* Initializes OTBN and starts the OTBN routine to compute the digital

\* signature on the input message. The domain_parameter field of the

\* \`elliptic_curve\` is required only for a custom curve. For named

\* curves this field is ignored and can be set to NULL.

\*

\* \@param private_key Pointer to the blinded private key (d) struct

\* \@param input_message Input message to be signed

\* \@param elliptic_curve Pointer to the elliptic curve to be used

\* \@return crypto_status_t Result of async ECDSA start operation

\*/

**crypto\_status\_t** **otcrypto\_ecdsa\_sign\_async\_start**(\
const **crypto\_blinded\_key\_t **\*private_key,\
**crypto\_const\_uint8\_buf\_t **input_message,\
**ecc\_curve\_t** \*elliptic_curve);

/\*\*

\* Finalizes the asynchronous ECDSA digital signature generation.

\*

\* Returns \`kCryptoStatusOK\` and copies the signature if the OTBN

\* status is done, or \`kCryptoStatusAsyncIncomplete\` if the OTBN is

\* busy or \`kCryptoStatusInternalError\` if there is an error.

\*

\* \@param signature Pointer to the signature struct with (r,s) values

\* \@return crypto_status_t Result of async ECDSA finalize operation

\*/

**crypto\_status\_t**
**otcrypto\_ecdsa\_sign\_async\_finalize**(**ecc\_signature\_t**
\*signature);

Asynchronous - Deterministic ECDSA Signature

/\*\*

\* Starts the asynchronous deterministic ECDSA signature generation.

\*

\* Initializes OTBN and starts the OTBN routine to compute the digital

\* signature on the input message. The domain_parameter field of the

\* \`elliptic_curve\` is required only for a custom curve. For named

\* curves this field is ignored and can be set to NULL.

\*

\* \@param private_key Pointer to the blinded private key (d) struct

\* \@param input_message Input message to be signed

\* \@param elliptic_curve Pointer to the elliptic curve to be used

\* \@return crypto_status_t Result of async deterministic ECDSA start

\* operation

\*/

**crypto\_status\_t**
**otcrypto\_deterministic\_ecdsa\_sign\_async\_start**(\
const **crypto\_blinded\_key\_t **\*private_key,\
**crypto\_const\_uint8\_buf\_t **input_message,\
**ecc\_curve\_t** \*elliptic_curve);

/\*\*

\* Finalizes the asynchronous deterministic ECDSA digital signature

\* generation.

\*

\* In the case of deterministic ECDSA, the random value 'k'for the

\* signature generation is deterministically generated from the

\* private key and the input message. Refer to for details.

\*

\* Returns \`kCryptoStatusOK\` and copies the signature if the OTBN

\* status is done, or \`kCryptoStatusAsyncIncomplete\` if the OTBN is

\* busy or \`kCryptoStatusInternalError\` if there is an error.

\*

\* \@param signature Pointer to the signature struct with (r,s) values

\* \@return crypto_status_t Result of async deterministic ECDSA

\* finalize operation

\*/

**crypto\_status\_t**
**otcrypto\_ecdsa\_deterministic\_sign\_async\_finalize**(\
**ecc\_signature\_t** \*signature);

Asynchronous - ECDSA Verification

/\*\*

\* Starts the asynchronous ECDSA digital signature verification.

\*

\* Initializes OTBN and starts the OTBN routine to recover 'r'value

\* from the input signature 's'value. The domain_parameter field of

\* \`elliptic_curve\` is required only for a custom curve. For named

\* curves this field is ignored and can be set to NULL.

\*

\* \@param public_key Pointer to the unblinded public key (Q) struct

\* \@param input_message Input message to be signed for verification

\* \@param signature Pointer to the signature to be verified

\* \@param elliptic_curve Pointer to the elliptic curve to be used

\* \@return crypto_status_t Result of async ECDSA verify start function

\*/

**crypto\_status\_t** **otcrypto\_ecdsa\_verify\_async\_start** (\
const **ecc\_public\_key\_t** \*public_key,\
** crypto\_const\_uint8\_buf\_t **input_message,\
**ecc\_signature\_t** \*signature,\
** ecc\_curve\_t** \*elliptic_curve);

/\*\*

\* Finalizes the asynchronous ECDSA digital signature verification.

\*

\* Returns \`kCryptoStatusOK\` and populates the \`verification result\`

\* if the OTBN status is done. \`kCryptoStatusAsyncIncomplete\` if the

\* OTBN is busy or \`kCryptoStatusInternalError\` if there is an error.

\* The computed signature is compared against the input signature

\* and a PASS or FAIL is returned.

\*

\* \@param verification_result Returns the result of verification

\* \@return crypto_status_t Result of async ECDSA verify finalize

\* operation

\*/

**crypto\_status\_t** **otcrypto\_ecdsa\_verify\_async\_finalize** (\
**verification\_status\_t **\*verification_result);

Asynchronous - ECDH Key Gen

/\*\*

\* Starts the asynchronous key generation for ECDH operation.

\*

\* Initializes OTBN and starts the OTBN routine to compute the private

\* key (d) and public key (Q) for ECDH operation.

\*

\* The domain_parameter field of the \`elliptic_curve\` is required

\* only for a custom curve. For named curves this field is ignored

\* and can be set to NULL.

\*

\* Returns \`kCryptoStatusOK\` if the operation was successfully

\* started, or\`kCryptoStatusInternalError\` if the operation cannot be

\* started.

\*

\* \@param elliptic_curve Pointer to the elliptic curve to be used

\* \@return crypto_status_t Result of asynchronous ECDH keygen start

\* operation.

\*/

**crypto\_status\_t** **otcrypto\_ecdh\_keygen\_async\_start**(\
**ecc\_curve\_t** \*elliptic_curve);

/\*\*

\* Finalizes the asynchronous key generation for ECDSA operation.

\*

\* Returns \`kCryptoStatusOK\` and copies the private key (d) and public

\* key (Q), if the OTBN status is done, or

\* \`kCryptoStatusAsyncIncomplete\` if the OTBN is busy or

\* \`kCryptoStatusInternalError\` if there is an error.

\*

\* \@param private_key Pointer to the blinded private key (d) struct

\* \@param public_key Pointer to the unblinded public key (Q) struct

\* \@return crypto_status_t Result of asynchronous ECDH keygen

\* finalize operation

\*/

**crypto\_status\_t** **otcrypto\_ecdh\_keygen\_async\_finalize**(\
** crypto\_blinded\_key\_t **\*private_key,\
** ecc\_public\_key\_t **\*public_key);

Asynchronous - ECDH

/\*\*

\* Starts the asynchronous Elliptic Curve Diffie Hellman shared

\* secret generation.

\*

\* The domain_parameter field of the \`elliptic_curve\` is required

\* only for a custom curve. For named curves this field is ignored

\* and can be set to NULL.

\*

\* \@param private_key Pointer to the blinded private key (d) struct

\* \@param public_key Pointer to the unblinded public key (Q) struct

\* \@param elliptic_curve Pointer to the elliptic curve to be used

\* \@return crypto_status_t Result of async ECDH start operation

\*/

**crypto\_status\_t** **otcrypto\_ecdh\_async\_start**(\
const **crypto\_blinded\_key\_t **\*private_key,\
const **ecc\_public\_key\_t** \*public_key,\
**ecc\_curve\_t** \*elliptic_curve);

/\*\*

\* Finalizes the asynchronous Elliptic Curve Diffie Hellman shared

\* secret generation.

\*

\* Returns \`kCryptoStatusOK\` and copies \`shared_secret\` if the OTBN

\* status is done, or \`kCryptoStatusAsyncIncomplete\` if the OTBN

\* is busy or \`kCryptoStatusInternalError\` if there is an error.

\*

\* \@param shared_secret Pointer to generated blinded shared key struct

\* \@return crypto_status_t Result of async ECDH finalize operation

\*/

**crypto\_status\_t** **otcrypto\_ecdh\_async\_finalize**(\
**crypto\_blinded\_key\_t **\*shared_secret);

Asynchronous - Ed25519 Key Gen

/\*\*

\* Starts the asynchronous key generation for Ed25519.

\*

\* Initializes OTBN and starts the OTBN routine to compute the private

\* exponent (d) and public key (Q) based on Curve25519.

\*

\* No domain_parameter is needed and is automatically set for X25519.

\*

\* \@param drbg_state Pointer to the DRBG working state

\* \@param additional_input Pointer to the additional input for DRBG

\* \@return crypto_status_t Result of asynchronous ed25519 keygen start

\* operation.

\*/

**crypto\_status\_t** **otcrypto\_ed25519\_keygen\_async\_start**( );

/\*\*

\* Finalizes the asynchronous key generation for Ed25519.

\*

\* Returns \`kCryptoStatusOK\` and copies private key (d) and public key

\* (Q), if the OTBN status is done, or \`kCryptoStatusAsyncIncomplete\`

\* if the OTBN is busy or \`kCryptoStatusInternalError\` if there is an

\* error.

\*

\* \@param private_key Pointer to the blinded private key struct

\* \@param public_key Pointer to the unblinded public key struct

\* \@return crypto_status_t Result of asynchronous ed25519 keygen

\* finalize operation.

\*/

**crypto\_status\_t** **otcrypto\_ed25519\_keygen\_async\_finalize**(\
**crypto\_blinded\_key\_t **\*private_key,\
**crypto\_unblinded\_key\_t** \*public_key);

Asynchronous - Ed25519 Signature

/\*\*

\* Starts the asynchronous Ed25519 digital signature generation.

\*

\* Initializes OTBN and starts the OTBN routine to compute the digital

\* signature on the input message. The domain_parameter field for

\* Ed25519 is automatically set.

\*

\* \@param private_key Pointer to the blinded private key struct

\* \@param input_message Input message to be signed

\* \@param sign_mode Parameter for EdDSA or Hash EdDSA sign mode

\* \@param signature Pointer to the EdDSA signature to get (r) value

\* \@return crypto_status_t Result of async Ed25519 start operation

\*/

**crypto\_status\_t** **otcrypto\_ed25519\_sign\_async\_start**(\
const **crypto\_blinded\_key\_t **\*private_key,\
** crypto\_const\_uint8\_buf\_t **input_message,\
** eddsa\_sign\_mode\_t** sign_mode,\
**ecc\_signature\_t** \*signature);

/\*\*

\* Finalizes the asynchronous Ed25519 digital signature generation.

\*

\* Returns \`kCryptoStatusOK\` and copies the signature if the OTBN

\* status is done, or \`kCryptoStatusAsyncIncomplete\` if the OTBN is

\* busy or \`kCryptoStatusInternalError\` if there is an error.

\*

\* \@param signature Pointer to the EdDSA signature to get (s) value

\* \@return crypto_status_t Result of async Ed25519 finalize operation

\*/

**crypto\_status\_t** **otcrypto\_ed25519\_sign\_async\_finalize**(\
**ecc\_signature\_t** \*signature);

Asynchronous - Ed25519 Verification

/\*\*

\* Starts the asynchronous Ed25519 digital signature verification.

\*

\* Initializes OTBN and starts the OTBN routine to verify the

\* signature. The domain_parameter for Ed25519 is set automatically.

\*

\* \@param public_key Pointer to the unblinded public key struct

\* \@param input_message Input message to be signed for verification

\* \@param sign_mode Parameter for EdDSA or Hash EdDSA sign mode

\* \@param signature Pointer to the signature to be verified

\* \@param verification_result Returns the result of signature

\* verification (Pass/Fail)

\* \@return crypto_status_t Result of async Ed25519 verification start

\* function

\*/

**crypto\_status\_t** **otcrypto\_ed25519\_verify\_async\_start**(\
const **crypto\_unblinded\_key\_t **\*public_key,\
** crypto\_const\_uint8\_buf\_t **input_message,\
** eddsa\_sign\_mode\_t** sign_mode,\
**ecc\_signature\_t** \*signature);

/\*\*

\* Finalizes the asynchronous Ed25519 digital signature verification.

\*

\* Returns \`kCryptoStatusOK\` and populates the \`verification result\`

\* with a PASS or FAIL, if the OTBN status is done,

\* \`kCryptoStatusAsyncIncomplete\` if the OTBN is busy or

\* \`kCryptoStatusInternalError\` if there is an error.

\*

\* \@param verification_result Returns the result of verification

\* \@return crypto_status_t Result of async Ed25519 verification

\* finalize function

\*/

**crypto\_status\_t** **otcrypto\_ed25519\_verify\_async\_finalize**(\
**verification\_status\_t **\*verification_result);

Asynchronous - X25519 Key Gen

/\*\*

\* Starts the asynchronous key generation for X25519.

\*

\* Initializes OTBN and starts the OTBN routine to compute the private

\* exponent (d) and public key (Q) based on Curve25519.

\*

\* No domain_parameter is needed and is automatically set for X25519.

\*

\* \@param drbg_state Pointer to the DRBG working state

\* \@param additional_input Pointer to the additional input for DRBG

\* \@return crypto_status_t Result of asynchronous X25519 keygen start

\* operation.

\*/

**crypto\_status\_t** **otcrypto\_x25519\_keygen\_async\_start**( );

/\*\*

\* Finalizes the asynchronous key generation for X25519.

\*

\* Returns \`kCryptoStatusOK\` and copies private key (d) and public key

\* (Q), if the OTBN status is done, or \`kCryptoStatusAsyncIncomplete\`

\* if the OTBN is busy or \`kCryptoStatusInternalError\` if there is an

\* error.

\*

\* \@param private_key Pointer to the blinded private key struct

\* \@param public_key Pointer to the unblinded public key struct

\* \@return crypto_status_t Result of asynchronous X25519 keygen

\* finalize operation.

\*/

**crypto\_status\_t** **otcrypto\_x25519\_keygen\_async\_finalize**(\
**crypto\_blinded\_key\_t **\*private_key,\
** crypto\_unblinded\_key\_t** \*public_key);

Asynchronous - X25519 key exchange

/\*\*

\* Starts the asynchronous X25519 Diffie Hellman shared secret

\* generation.

\*

\* Initializes OTBN and starts the OTBN routine to perform Diffie

\* Hellman shared secret generation based on Curve25519. The

\* domain parameter is automatically set for X25519 API.

\*

\* \@param private_key Pointer to the blinded private key

\* (u-coordinate)

\* \@param public_key Pointer to the public scalar from the sender

\* \@return crypto_status_t Result of the async X25519 start operation

\*/

**crypto\_status\_t** **otcrypto\_x25519\_async\_start**(\
const **crypto\_blinded\_key\_t** \*private_key,\
** **const **crypto\_unblinded\_key\_t **\*public_key);

/\*\*

\* Finalizes the asynchronous X25519 Diffie Hellman shared secret

\* generation.

\*

\* Returns \`kCryptoStatusOK\` and copies \`shared_secret\` if the OTBN

\* status is done, or \`kCryptoStatusAsyncIncomplete\` if the OTBN

\* is busy or \`kCryptoStatusInternalError\` if there is an error.

\*

\* \@param shared_secret Pointer to shared secret key (u-coordinate)

\* \@return crypto_status_t Result of async X25519 finalize operation

\*/

**crypto\_status\_t** **otcrypto\_x25519\_async\_finalize**(\
** crypto\_blinded\_key\_t **\*shared_secret);

DRBG

Random bit generators (RBG) are used to generate cryptographically
secure random bits. The random bits can be generated using a
non-deterministic random bit generator (NRBG) or a deterministic random
bit generator (DRBG).

The DRBG module generates (deterministic) pseudo-random bits from an
input seed (entropy) value, using an underlying algorithm such as HASH,
HMAC or AES. These random bits are then used directly or after
processing, by the application in need of random values.

OpenTitan's random bit generator, (Cryptographically Secure Random
Number Generator) uses a block cipher based DRBG mechanism
(AES_CTR_DRBG) as specified in . OpenTitan's RNG targets compliance with
both , as well as and . The CSRNG operates at 256 bit security strength.

Based on the requirements from the , APIs are defined in the to support
DRBG mechanisms such as DRBG Instantiate, Reseed, Generate and
Uninstantiate.

The APIs for DRBG Instantiate and Reseed support two ways of obtaining
the required entropy: In an **auto entropy **mode the required entropy
is provided by the CSRNG IP (which gets its entropy from the ENTROPY_SRC
module) and in the **manual entropy **mode the required entropy is
obtained from the user as an input parameter. The user-provided entropy
generates deterministic pseudo-random bits from a known seed.

\
The picture below shows an example of a functional model of a DRBG.

**DRBG Functional Model**

A DRBG mechanism takes several parameters as input such as: Entropy
input, nonce, personalization string and additional input, based on its
operating mode.

To learn more about these input parameters and other details such as
DRBG mechanism, entropy requirements, seed construction, derivation
function and prediction resistance, kindly refer to the , , and
documents and the links in the section.

API

NOTE:

1.  The \`drbg_entropy_mode\` context parameter is used to disallow
    mixing of DRBG operations with auto entropy and (user-provided)
    manual entropy

2.  Entropy length - **The accepted entropy length is 384bits**. The API
    will reject the user provided entropy if the length is not 384-bits
    (24 bytes).

**AUTO ENTROPY**

The entropy for instantiation and reseed is [automatically
provided]{.underline} by the CSRNG IP, which gets its entropy from the
ENTROPY_SRC module.

DRBG-CTR-INSTANTIATE

/\*\*

\* Instantiates the DRBG system.

\*

\* Initializes the DRBG and the context for DRBG. Gets the required

\* entropy input automatically from the entropy source.

\*

\* \@param drbg_state Pointer to the DRBG working state

\* \@param nonce Pointer to the nonce bit-string

\* \@param perso_string Pointer to personalization bitstring

\* \@return crypto_status_t Result of the DRBG instantiate operation

\*/

**crypto\_status\_t** **otcrypto\_drbg\_instantiate**(**drbg\_state\_t**
\*drbg_state,\
** crypto\_uint8\_buf\_t** nonce,\
** crypto\_uint8\_buf\_t** perso_string);

DRBG-CTR-RESEED

/\*\*

\* Reseeds the DRBG with fresh entropy.

\*

\* Reseeds the DRBG with fresh entropy that is automatically fetched

\* from the entropy source and updates the working state parameters.

\*

\* \@param drbg_state Pointer to the DRBG working state

\* \@param additional_input Pointer to the additional input for DRBG

\* \@return crypto_status_t Result of the DRBG reseed operation

\*/

**crypto\_status\_t** **otcrypto\_drbg\_reseed**(**drbg\_state\_t**
\*drbg_state,\
**crypto\_uint8\_buf\_t **additional_input);

**MANUAL ENTROPY **

The entropy required for instantiation and reseed is manually provided
to the APIs, by the user.

DRBG-CTR-MANUAL-INSTANTIATE

/\*\*

\* Instantiates the DRBG system.

\*

\* Initializes DRBG and the DRBG context. Gets the required entropy

\* input from the user through the \`entropy\` parameter.

\*

\* \@param drbg_state Pointer to the DRBG working state

\* \@param entropy Pointer to the user defined entropy value

\* \@param nonce Pointer to the nonce bit-string

\* \@param personalization_string Pointer to personalization bitstring

\* \@return crypto_status_t Result of the DRBG manual instantiation

\*/

**crypto\_status\_t** **otcrypto\_drbg\_manual\_instantiate**(\
** drbg\_state\_t** \*drbg_state,\
** crypto\_uint8\_buf\_t **entropy,\
** crypto\_uint8\_buf\_t **nonce,\
** crypto\_uint8\_buf\_t **perso_string);

DRBG-CTR-MANUAL-RESEED

/\*\*

\* Reseeds the DRBG with fresh entropy.

\*

\* Reseeds the DRBG with entropy input from the user through \`entropy\`

\* parameter and updates the working state parameters.

\*

\* \@param drbg_state Pointer to the DRBG working state

\* \@param entropy Pointer to the user defined entropy value

\* \@param additional_input Pointer to the additional input for DRBG

\* \@return crypto_status_t Result of the manual DRBG reseed operation

\*/

**crypto\_status\_t** **otcrypto\_drbg\_manual\_reseed**(\
**drbg\_state\_t** \*drbg_state,\
** crypto\_uint8\_buf\_t** entropy,\
** crypto\_uint8\_buf\_t** additional_input);

DRBG-CTR-GENERATE

/\*\*

\* DRBG function for generating random bits.

\*

\* Used to generate pseudo random bits after DRBG instantiation or

\* DRBG reseeding.

\*

\* The caller should allocate space for the \`drbg_output\` buffer,\
\* (of length \`output_len\`), and set the length of expected

\* output in the \`len\` field of \`drbg_output\`. If the user-set
length

\* and the output length does not match, an error message will be

\* returned.

\*

\* \@param drbg_state Pointer to the DRBG working state

\* \@param additional_input Pointer to the additional data

\* \@param output_len Required length of pseudorandom output, in bytes

\* \@param drbg_output Pointer to the generated pseudo random bits

\* \@return crypto_status_t Result of the DRBG generate operation

\*/

**crypto\_status\_t** **otcrypto\_drbg\_generate**(**drbg\_state\_t**
\*drbg_state,\
** crypto\_uint8\_buf\_t **additional_input,\
** size\_t** output_len,\
** crypto\_uint8\_buf\_t** \*drbg_output);

DRBG-CTR-UNINSTANTIATE

/\*\*

\* Uninstantiates DRBG and clears the context.

\*

\* \@param drbg_state Pointer to the DRBG working state

\* \@return crypto_status_t Result of the DRBG uninstantiate operation

\*/

**crypto\_status\_t**
**otcrypto\_drbg\_uninstantiate**(**drbg\_state\_t** \*drbg_state);

KDF

OpenTitan Key derivation functions (KDF) provide key-expansion
capability. Key derivation functions can be used to derive additional
keys from a cryptographic key that has been established through an
automated key-establishment scheme or from a pre-shared key.

The OpenTitan key derivation function is based on the counter mode and
uses a pseudorandom function (PRF) as a building block. OpenTitan KDF
function supports a user-selectable PRF as the engine (i.e. either HMAC
or a KMAC).

To learn more about PRFs, various key derivation mechanisms and security
considerations, kindly refer to the and the links in the section.

API

KDF_CTR

/\*\*

\* Performs the key derivation function in counter mode.

\*

\* The required PRF engine for the KDF function is selected using the

\* \`kdf_mode\` parameter.

\*

\* \@param key_derivation_key Pointer to the blinded key derivation key

\* \@param kdf_mode Required KDF mode, with HMAC or KMAC as a PRF

\* \@param key_mode Crypto mode for which the derived key is intended

\* \@param required_bit_len Required length of the derived key in bits

\* \@param keying_material Pointer to the blinded keying material

\* \@return crypto_status_t Result of the key derivation operation

\*/

**crypto\_status\_t** **otcrypto\_kdf\_ctr**(const
**crypto\_blinded\_key\_t** key_derivation_key,\
** kdf\_type\_t** kdf_mode,\
** key\_mode\_t** key_mode,\
** size\_t** required_bit_len,\
** crypto\_blinded\_key\_t** keying_material);

Key Import and Export

The following section defines the APIs required to import and export
keys.

Import key function takes a user key in plain and generates an OpenTitan
specific unblinded (not-masked) or blinded (masked with 'n'shares) key
struct. The export function unloads the blinded key to an unblinded key
from which the user can read the plain key when required.

API

Build unblinded key

/\*\*

\* Builds an unblinded key struct from a user (plain) key.

\*

\* \@param plain_key Pointer to the user defined plain key

\* \@param key_mode Crypto mode for which the key usage is intended

\* \@param unblinded_key Generated unblinded key struct

\* \@return crypto_status_t Result of the build unblinded key operation

\*/

**crypto\_status\_t** **otcrypto\_build\_unblinded\_key**(\
**crypto\_const\_uint8\_buf\_t **plain_key,\
**key\_mode\_t** key_mode,\
**crypto\_unblinded\_key\_t **unblinded_key);

Build blinded key

/\*\*

\* Builds a blinded key struct from a plain key.

\*

\* This API takes as input a plain key from the user and masks

\* it using an implantation specific masking with 'n'shares and

\* generates a blinded key struct as output.

\*

\* \@param plain_key Pointer to the user defined plain key

\* \@param key_mode Crypto mode for which the key usage is intended

\* \@param blinded_key Generated blinded key struct

\* \@return crypto_status_t Result of the build blinded key operation

\*/

**crypto\_status\_t** **otcrypto\_build\_blinded\_key**(\
**crypto\_const\_uint8\_buf\_t** plain_key,\
**key\_mode\_t** key_mode,\
**crypto\_blinded\_key\_t **blinded_key);

Blinded key to Unblinded key

/\*\*

\* Exports the blinded key struct to an unblinded key struct.

\*

\* This API takes as input a blinded key masked with 'n'shares,

\* removes the masking and generates an unblinded key struct as

\* output.

\*

\* \@param blinded_key Blinded key struct to be unmasked

\* \@param unblinded_key Generated unblinded key struct

\* \@return crypto_status_t Result of the blinded key export operation

\*/

**crypto\_status\_t** **otcrypto\_blinded\_to\_unblinded\_key**(\
const **crypto\_blinded\_key\_t** blinded_key,\
**crypto\_unblinded\_key\_t** unblinded_key);

Unblinded key to Blinded key

/\*\*

\* Build a blinded key struct from an unblinded key struct.

\*

\* \@param unblinded_key Blinded key struct to be unmasked

\* \@param blinded_key Generated (unmasked) unblinded key struct

\* \@return crypto_status_t Result of unblinded key export operation

\*/

**crypto\_status\_t** **otcrypto\_unblinded\_to\_blinded\_key**(\
const **crypto\_unblinded\_key** unblinded_key,\
**crypto\_blinded\_key\_t **blinded_key);

Security Strength

Security strength in simple terms denotes the amount of work required to
break a cryptographic algorithm. Security strength of an algorithm with
key length 'k'is expressed in "bits" where n-bit security means that the
attacker would have to perform 2^n^ operations to break the algorithm.

The table below summarizes the security strength for all the .

+----------------+----------------+----------------+----------------+
| **Family**     | **Algo**       | **Security     | **Comments**   |
|                |                | Strength       |                |
|                |                | (bits)**       |                |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
| Symmetric-key  | AES128         | 128            |                |
| block ciphers  |                |                |                |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | AES192         | 192            |                |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | AES256         | 256            |                |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
| HASH           | SHA256         | 128            | 128 bits for   |
|                |                |                | Collision      |
|                |                |                | Resistance,\   |
|                |                |                | 256 bits for   |
|                |                |                | Preimage       |
|                |                |                | Resistance     |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | SHA384         | 192            | 192 bits for   |
|                |                |                | Collision      |
|                |                |                | Resistance,\   |
|                |                |                | 384 bits for   |
|                |                |                | Preimage       |
|                |                |                | Resistance     |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | SHA512         | 256            | 256 bits for   |
|                |                |                | Collision      |
|                |                |                | Resistance,\   |
|                |                |                | 512 bits for   |
|                |                |                | Preimage       |
|                |                |                | Resistance     |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | SHA3-224       | 112            | 112 bits for   |
|                |                |                | Collision      |
|                |                |                | Resistance,\   |
|                |                |                | 224 bits for   |
|                |                |                | Preimage       |
|                |                |                | Resistance     |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | SHA3-256       | 128            | 128 bits for   |
|                |                |                | Collision      |
|                |                |                | Resistance,\   |
|                |                |                | 256 bits for   |
|                |                |                | Preimage       |
|                |                |                | Resistance     |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | SHA3-384       | 192            | 192 bits for   |
|                |                |                | Collision      |
|                |                |                | Resistance,\   |
|                |                |                | 384 bits for   |
|                |                |                | Preimage       |
|                |                |                | Resistance     |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | SHA3-512       | 256            | 256 bits for   |
|                |                |                | Collision      |
|                |                |                | Resistance,\   |
|                |                |                | 512 bits for   |
|                |                |                | Preimage       |
|                |                |                | Resistance     |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
| HASH-XOF       | SHAKE128       | Output         | For output     |
|                |                | 'd'bits\       | size of        |
|                |                | min(d/2,128)   | 'd'bits,\      |
|                |                |                | Collision      |
|                |                |                | Resistance:    |
|                |                |                | min(d/2,128)\  |
|                |                |                | Preimage       |
|                |                |                | Resistance:    |
|                |                |                | ≥min(d,128)    |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | SHAKE256       | Output         | For output     |
|                |                | 'd'bits\       | size of        |
|                |                | min(d/2,256)   | 'd'bits,\      |
|                |                |                | Collision      |
|                |                |                | Resistance:    |
|                |                |                | min(d/2,256)\  |
|                |                |                | Preimage       |
|                |                |                | Resistance:    |
|                |                |                | ≥min(d,256)    |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | cSHAKE128      | 128            |                |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | cSHAKE256      | 256            |                |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
| \              | HMAC-SHA256    | 256            |                |
| MAC            |                |                |                |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | KMAC128        | 128            |                |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | KMAC256        | 256            |                |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
| RSA            | Modulus 1024   | 80             | Legacy, not    |
|                | bits           |                | recommended    |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | Modulus 2048   | 112            |                |
|                | bits           |                |                |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | Modulus 3072   | 128            |                |
|                | bits           |                |                |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | Modulus 4096   | \~144          |                |
|                | bits           |                |                |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
| ECC            | NIST P256      | 128            | Key size       |
|                |                |                | {256-383}      |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | NIST P384      | 192            | Key size       |
|                |                |                | {384-511}      |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
|                | Curve25519     | 128            |                |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
| DRBG           | CTR_DRBG       | 256            | Based on       |
|                |                |                | AES-CTR-256    |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+
| KDF            | KDF_CTR        | 128            | With HMAC or   |
|                |                |                | KMAC as a PRF  |
+----------------+----------------+----------------+----------------+
|                |                |                |                |
+----------------+----------------+----------------+----------------+

Over time the cryptographic algorithms may become more vulnerable to
successful attacks, requiring a transition to stronger algorithms or
longer key lengths over time. The table below is a recommendation from ,
that provides a projected time frame for applying cryptographic
protection at a minimum security strength.

**NIST Security strength time frames**

Kindly refer to the security strength links in the section for more
information on crypto algorithms, key sizes and related security
strength and transition recommendations.

## Reference


**General**
1. [OpenTitan Cryptography Use Case Table][use-case-table]
2. [Asynchronous mode of operation for OpenTitan][async-proposal]

**AES**
1. [FIPS 197][aes-spec]: Announcing the Advanced Encryption Standard (AES)
2. [NIST SP800-38A][aes-basic-modes-spec]: Recommendation for Block Cipher Modes of Operation: Methods and Techniques
3. [NIST SP800-38D][gcm-spec]: Recommendation for Block Cipher Modes of Operation: Galois/Counter Mode (GCM) and GMAC
4. [NIST SP800-38F][kwp-spec]: Recommendation for Block Cipher Modes of Operation: Methods for Key wrapping

**HASH**
1. [FIPS 180-4][sha2-spec]: Secure Hash Standard
2. [FIPS 202][sha3-spec]: SHA-3 Standard: Permutation-Based Hash and Extendable-Output Functions
3. [NIST SP800-185][sha3-derived-spec]: SHA-3 Derived Functions: cSHAKE, KMAC, TupleHash, and ParallelHash

**MAC**
1. [IETF RFC 2104][hmac-rfc]: HMAC: Keyed-Hashing for Message Authentication
2. [IETF RFC 4231][hmac-testvectors-rfc]: Identifiers and Test Vectors for HMAC-SHA-224, HMAC-SHA-256, HMAC-SHA-384, and HMAC-SHA-512
3. [IETF RFC 4868][hmac-usage-rfc]: Using HMAC-SHA-256, HMAC-SHA-384, and HMAC-SHA-512
4. [NIST SP800-185][sha3-derived-spec]: SHA-3 Derived Functions: cSHAKE, KMAC, TupleHash, and ParallelHash

**RSA**
1. [IETF RFC 8017][rsa-rfc]: PKCS #1: RSA Cryptography Specifications Version 2.2
2. [FIPS 186-5][fips-186]: Digital Signature Standard

**ECC**
1. [SEC1][sec1]: Elliptic Curve Cryptography
2. [SEC2][sec2]: Recommended Elliptic Curve Domain Parameters
3. [FIPS 186-5][fips-186]: Digital Signature Standard
4. [NIST SP800-56A][ecdh-spec]: Recommendation for Pair-Wise Key-Establishment Schemes Using Discrete Logarithm Cryptography
5. [IETF RFC 5639][brainpool-rfc]: Elliptic Curve Cryptography (ECC) Brainpool Standard Curves and Curve Generation
6. [IETF RFC 4492][ecc-tls-rfc]: Elliptic Curve (ECC) Cipher Suites for Transport Layer Security (TLS)
7. [Safe curves][safe-curves]: Choosing safe curves for elliptic-curve cryptography
8. [IETF RFC 7448][ecc-rfc]: Elliptic Curves for Security
9. [IETF RFC 8032][eddsa-rfc]: Edwards-Curve Digital Signature Algorithm (EdDSA)
10. [NIST SP800-186][nist-ecc-domain-params]: Recommendations for Discrete Logarithm-Based Cryptography: Elliptic Curve Domain Parameters

**DRBG**
1. [NIST SP800-90A][nist-drbg-spec]: Recommendation for Random Number Generation Using Deterministic Random Bit Generators
2. [NIST SP800-90B][nist-entropy-spec]: Recommendation for the Entropy Sources Used for Random Bit Generation
3. [BSI-AIS31][bsi-ais31]: A proposal for: Functionality classes for random number generators
4. OpenTitan [CSRNG block][csrng] technical specification

**Key Derivation**
1. [NIST SP800-108][kdf-spec]: Recommendation for Key Derivation using Pseudorandom Functions

**Key Management, Security Strength**
1. [NIST SP800-131][nist-sp800-131a]: Transitioning the Use of Cryptographic Algorithms and Key Lengths
2. [NIST-SP800-57][nist-sp800-57]: Recommendation for Key Management (Part 1 General)

[aes]: ../../../hw/ip/aes/README.md
[aes-spec]: https://csrc.nist.gov/publications/detail/fips/197/final
[aes-basic-modes-spec]: https://csrc.nist.gov/publications/detail/sp/800-38a/final
[async-proposal]: https://docs.google.com/document/d/1tOUYNEvcPuGgx0KIfDpSn2mKVJCVVm_EuimVQcRJtNI
[brainpool-rfc]: https://datatracker.ietf.org/doc/html/rfc5639
[bsi-ais31]: https://www.bsi.bund.de/SharedDocs/Downloads/EN/BSI/Certification/Interpretations/AIS_31_Functionality_classes_for_random_number_generators_e.html
[csrng]:  ../../../hw/ip/csrng/README.md
[ecc-rfc]: https://datatracker.ietf.org/doc/html/rfc7448
[ecc-tls-rfc]: https://datatracker.ietf.org/doc/html/rfc4492
[ecdh-spec]: https://csrc.nist.gov/publications/detail/sp/800-56a/rev-3/final
[eddsa-rfc]: https://datatracker.ietf.org/doc/html/rfc8032
[fips-186]: https://csrc.nist.gov/publications/detail/fips/186/5/final
[gcm-spec]: https://csrc.nist.gov/publications/detail/sp/800-38d/final
[hmac-rfc]: https://datatracker.ietf.org/doc/html/rfc2104
[hmac-testvectors-rfc]: https://datatracker.ietf.org/doc/html/rfc4231
[hmac-usage-rfc]: https://datatracker.ietf.org/doc/html/rfc4868
[kdf-spec]: https://csrc.nist.gov/publications/detail/sp/800-108/final
[kmac]:  ../../../hw/ip/kmac/README.md
[kwp-spec]: https://csrc.nist.gov/publications/detail/sp/800-38f/final
[nist-drbg-spec]: https://csrc.nist.gov/publications/detail/sp/800-90a/rev-1/final
[nist-ecc-domain-params]: https://csrc.nist.gov/publications/detail/sp/800-186/final
[nist-entropy-spec]: https://csrc.nist.gov/publications/detail/sp/800-90b/final
[nist-sp800-131a]: https://csrc.nist.gov/publications/detail/sp/800-131a/rev-2/final
[nist-sp800-57]: https://csrc.nist.gov/publications/detail/sp/800-57-part-1/rev-5/final
[otbn]: ../../../hw/ip/otbn/README.md
[rsa-rfc]: https://datatracker.ietf.org/doc/html/rfc8017
[safe-curves]: https://safecurves.cr.yp.to/
[sec1]: https://www.secg.org/sec1-v2.pdf
[sec2]: https://www.secg.org/sec2-v2.pdf
[sha2-spec]: https://csrc.nist.gov/publications/detail/fips/180/4/final
[sha3-spec]: https://csrc.nist.gov/publications/detail/fips/202/final
[sha3-derived-spec]: https://csrc.nist.gov/publications/detail/sp/800-185/final
[use-case-table]: https://docs.google.com/document/d/1fHUUL4i39FJXk-lbVNDizVZSWObizGE2pTWVhQKb41c
