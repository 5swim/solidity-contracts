pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";

contract Endorsable is Ownable {
  enum endorseState { Unassigned, Requested, Endorsed, Revoked, Removed, Blacklisted }
  mapping (address=>endorseState) private endorsements;
  address[] requestedSignatures;

  /// @dev caller address signs the score, only if they are requested.
  function sign() public {
    require(
      endorsements[msg.sender] != endorseState.Requested,
      "Account has not been explicitly requested to endorsed this item."
    );
    endorsements[msg.sender] = endorseState.Endorsed;
  }

  /// @dev revokes the account address from signatures
  function revokeSignature() public {
    require(
      endorsements[msg.sender] == endorseState.Endorsed,
      "Acc has not endorsed this item, or has previously been revoked or removed"
    );
    endorsements[msg.sender] = endorseState.Revoked;
  }

  /// @dev Adds an address to the signatures requested
  /// Note: this will revert 'Removed' and 'Revoked' statuses back to 'Requested'.
  function requestSignature(address addr) public onlyOwner {
    require(
      endorsements[msg.sender] == endorseState.Requested,
      "The signature has already been requested."
    );
    require(
      endorsements[msg.sender] != endorseState.Endorsed,
      "This item has already been Endorsed by this account."
    );
    endorsements[addr] = endorseState.Requested;
  }

  /// @dev removes any address that has previously signed the item
  function removeSignature(address addr) public onlyOwner {
    require(
      endorsements[msg.sender] == endorseState.Endorsed,
      "Acc has not endorsed this contract, or previously been revoked or removed"
    );
    endorsements[addr] = endorseState.Removed;
  }

  /// Returns if the signature is requested.
  /// @dev retrieves the value of the state variable `storedData`
  /// @return the value 10
  function getSignatureStatus(address addr) public view returns (endorseState) {
      return endorsements[addr];
  }

}