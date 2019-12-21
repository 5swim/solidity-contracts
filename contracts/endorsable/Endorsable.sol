/*
The MIT License (MIT)
Copyright (c) 2019 5Swim Ltd.
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";

contract Endorsable is Ownable {
    enum endorseState { Unassigned, Requested, Endorsed, Revoked, Removed, Blacklisted}
    mapping (address=>endorseState) private endorsements;
    address[] requestedSignatures;

    /// @dev Empty internal constructor, to prevent people from mistakenly deploying
    /// an instance of this contract, which should be used via inheritance.
    // solium-disable-next-line
    constructor () internal { }

    /// @notice tx sender endorses the contract, only if requested to do so.
    /// @dev
    function endorse() public {
        require(
            endorsements[msg.sender] != endorseState.Requested,
            "Account has not been explicitly requested to endorsed this item."
        );
        endorsements[msg.sender] = endorseState.Endorsed;
    }

    /// @notice tx sender revokes thier address from endorsements
    /// @dev if not endorsed yet, it remains in the list as requested
    function revokeSignature() public {
        require(
            endorsements[msg.sender] == endorseState.Endorsed,
            "Acc has not yet endorsed the contract, or been previously revoked or removed"
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
    /// @dev retrieves the state of the endorsement
    /// @return an integer representing the endorsement state of the contract
    function getSignatureStatus(address addr) public view returns (endorseState) {
        return endorsements[addr];
    }

}