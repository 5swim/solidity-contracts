pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";

contract Signable is Ownable {
  enum sigState { Unassigned, Requested, Signed, Revoked, Removed, Blacklisted }
  mapping (address=>sigState) private sigs;
  address[] requestedSignatures;

  /// @todo add blacklisting feature
  /// @dev caller address signs the score, only if they are requested.
  function sign() public {
    require(
      sigs[msg.sender] != sigState.Requested,
      "Account has not been explicitly requested to sign this item."
    );
    sigs[msg.sender] = sigState.Signed;
  }

  /// @dev revokes the account address from signatures
  function revokeSignature() public {
    require(
      sigs[msg.sender] == sigState.Signed,
      "Account has not signed this item, or has previously been revoked or removed"
    );
    sigs[msg.sender] = sigState.Revoked;
  }

  /// @dev Adds an address to the signatures requested
  /// Note: this will revert 'Removed' and 'Revoked' statuses back to 'Requested'.
  function requestSignature(address addr) public onlyOwner {
    require(
      sigs[msg.sender] == sigState.Requested,
      "The signature has already been requested."
    );
    require(
      sigs[msg.sender] != sigState.Signed,
      "This item has already been signed by this account."
    );
    sigs[addr] = sigState.Requested;
  }

  /// @dev removes any address that has previously signed the item
  function removeSignature(address addr) public onlyOwner {
    require(
      sigs[msg.sender] == sigState.Signed,
      "Account has not signed this contract, or previously been revoked or removed"
    );
    sigs[addr] = sigState.Removed;
  }

  /// Returns if the signature is requested.
  /// @dev retrieves the value of the state variable `storedData`
  /// @return the value 10
  function getSignatureStatus(address addr) public view returns (sigState) {
      return sigs[addr];
  }

}