# EnergyProduction - Energy Production Certification Contract

## Overview
The **EnergyProduction** smart contract is designed to work alongside **WattConnect** to verify and certify energy production. It enables energy producers to apply for certification, authorized certifiers to approve certifications, and the contract owner to manage certification fees and policies. The contract also allows for revocation of certifications under specific conditions.

## Features
- **Certification Process:** Energy producers can apply for certification, and authorized certifiers can certify them.
- **Authorized Certifiers:** Only approved certifiers can issue certifications.
- **Certification Fees:** The contract enforces a fee for certification applications.
- **Revocation Mechanism:** The contract owner or authorized certifiers can revoke certifications for valid reasons.
- **Read-Only Queries:** Users can check certification status, retrieve producer data, and view certification fees.

## Contract Constants
| Constant | Description |
|----------|-------------|
| `contract-owner` | Owner of the contract (deployer) |
| `err-owner-only` | Error code for unauthorized owner actions (200) |
| `err-not-certified` | Error code for unverified producers (201) |
| `err-already-certified` | Error code for already certified producers (202) |
| `err-invalid-certifier` | Error code for invalid certifier actions (203) |
| `err-invalid-amount` | Error code for invalid energy production amount (204) |
| `err-not-authorized` | Error code for unauthorized access (205) |
| `err-invalid-fee` | Error code for invalid certification fee (206) |
| `err-invalid-minimum` | Error code for invalid minimum production requirement (207) |
| `err-invalid-string` | Error code for invalid energy source string (208) |
| `err-invalid-reason` | Error code for invalid revocation reason (209) |

## Data Variables
| Variable | Description |
|----------|-------------|
| `certification-fee` | Fee (in microstacks) required for certification (default: 1000 uSTX) |
| `minimum-production` | Minimum energy production required for certification (default: 100 kWh) |
| `max-fee` | Maximum allowed certification fee (default: 1,000,000 uSTX) |
| `max-production` | Maximum allowed production amount (default: 1,000,000 kWh) |

## Data Maps
| Map Name | Key | Value |
|----------|-----|-------|
| `certified-producers` | `principal` (producer) | `bool` (certified or not) |
| `authorized-certifiers` | `principal` (certifier) | `bool` (authorized or not) |
| `producer-energy-data` | `principal` (producer) | `{ total-production, last-certification-date, energy-source, certification-status, revocation-reason, revocation-date, revoked-by }` |

## Functions

### Private Functions
1. **`(is-authorized-certifier (certifier principal))`**
   - Checks if a given principal is an authorized certifier.

2. **`(validate-string (input (string-ascii 20)))`**
   - Ensures that input strings meet length requirements.

3. **`(validate-revocation-reason (reason (string-ascii 50)))`**
   - Ensures that the revocation reason is valid.

4. **`(can-revoke-certification (caller principal))`**
   - Checks if the caller has the authority to revoke a certification.

### Public Functions
1. **`(add-certifier (certifier principal))`**
   - Adds an authorized certifier (Only contract owner).

2. **`(remove-certifier (certifier principal))`**
   - Removes an authorized certifier (Only contract owner).

3. **`(apply-for-certification (energy-amount uint) (energy-source (string-ascii 20)))`**
   - Allows a producer to apply for certification with energy production data.

4. **`(certify-producer (producer principal))`**
   - Certifies a producer (Only authorized certifiers).

5. **`(revoke-certification (producer principal) (reason (string-ascii 50)))`**
   - Revokes certification from a producer (Only contract owner or authorized certifier).

6. **`(set-certification-fee (new-fee uint))`**
   - Updates the certification fee (Only contract owner).

7. **`(set-minimum-production (new-minimum uint))`**
   - Updates the minimum production requirement (Only contract owner).

### Read-Only Functions
1. **`(is-certified (producer principal))`**
   - Returns `true` if a producer is certified, `false` otherwise.

2. **`(get-producer-data (producer principal))`**
   - Retrieves certification details of a producer.

3. **`(get-certification-fee)`**
   - Returns the current certification fee.

## Usage Workflow
1. The **contract owner** adds authorized certifiers using `add-certifier`.
2. **Energy producers** apply for certification using `apply-for-certification`.
3. **Authorized certifiers** certify producers using `certify-producer`.
4. The **contract owner** or **authorized certifiers** can revoke certification if necessary using `revoke-certification`.
5. Users can check a producer’s certification status using `is-certified` or retrieve producer details using `get-producer-data`.

## Permissions
| Action | Allowed Users |
|--------|--------------|
| Add Certifier | Contract Owner |
| Remove Certifier | Contract Owner |
| Apply for Certification | Any Principal |
| Certify Producer | Authorized Certifiers |
| Revoke Certification | Contract Owner, Authorized Certifiers |
| Update Certification Fee | Contract Owner |
| Update Minimum Production | Contract Owner |
| Read Certification Status | Anyone |
| Read Producer Data | Anyone |

## Security Considerations
- **Authorization Checks:** Only authorized certifiers and contract owners can perform restricted actions.
- **Input Validation:** Strings and numbers are validated before storage.
- **Revocation Mechanism:** Certifications can be revoked with a valid reason to prevent abuse.
- **Fee Constraints:** Certification fees are restricted within a reasonable range.

## Conclusion
This contract ensures a secure and transparent system for verifying and certifying energy production. By enforcing strict authorization and validation rules, it maintains credibility and prevents fraudulent claims.

